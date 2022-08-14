(:~
 : DITA migration analysis web application
 :
 : 
 :)

module namespace dm="http://oasis-open.org/dita/dita-migration";

import module namespace migration="http://oasis-open.org/dita/modules/dita-migration" at './modules/dita-migration.xqy';

declare 
  %rest:GET
  %rest:path('/dita-migration')
  %rest:query-param('database', '{$database}')
  %output:method('html')
function dm:ditaMigrationRoot(
  $database as xs:string?
) as element(html) {
  let $selectedDatabase as xs:string? := 
     if (exists($database) and db:exists($database))
     then $database
     else ()
  return
  <html>
    <head>
      <title>DITA Migration Analysis Tool</title>
      <link href="/static/dita-migration.css" type="text/css" rel="stylesheet"/>
    </head>
    <body>
      <h1>DITA Migration Analysis Tool</h1>
      <article>
        <div>{
          if (empty($selectedDatabase))
          then dm:handleNoSelectedDatabase()
          else ()
        }</div>
        <div>{
          if (exists($selectedDatabase))
          then dm:generateMigrationReport($selectedDatabase)
          else <p>Select or create database.</p>
        }</div>
      </article>
      {dm:makePageFooter()}
    </body>
  </html>
};

declare 
  %rest:GET
  %rest:path('/dita-migration/migration-detail')
  %rest:query-param('database', '{$database}')
  %rest:query-param('item-id', '{$item-id}')
  %output:method('html')
function dm:ditaMigrationDetail(
  $database as xs:string,
  $item-id as xs:string
) as element(html) {
  let $migration-item as element(migration-item)? := $migration:migrationData/migration-item[@id eq $item-id]
  return
  if (exists($migration-item))
  then
  let $context as element()* := (migration:getMaps($database) | migration:getTopics($database))
  let $items := migration:evaluateExpression($context, $migration-item/xpath ! string(.))
  return
  <html>
    <head>
      <title>Migration Analysis Details: {$migration-item/title/node()}</title>
      <link href="/static/dita-migration.css" type="text/css" rel="stylesheet"/>
    </head>
    <body> 
      <h1>Migration Analysis Details: {$migration-item/title/node()}</h1>
      <article>
        <p>{$migration-item/description/node()}</p>
        <p>{$migration-item/migrate-to/node()}</p>
        <p>{count($items)} instances found.</p>
        <table class="report-table migration-detail-table">
          <thead>
            <tr>
              <th>Element</th>
              <th>Document Element</th>
              <th>Containing Document</th>
            </tr>
          </thead>
          <tbody>{
            for $item in $items
            let $docPath as xs:string := db:path($item)
            order by $docPath
            return 
            <tr>
              <td><pre>{serialize($item)}</pre></td>
              <td>{name(root($item)/*)}</td>
              <td>{$docPath}</td>
            </tr>
          }</tbody>
        </table>
      </article>
      {dm:makePageFooter()}
    </body>
  </html>
  else 
  <html>
    <head>
      <title>Migration Analysis Details</title>
      <link href="/static/dita-migration.css" type="text/css" rel="stylesheet"/>
    </head>
    <body>
      <article>
        <h1>Migration Analysis Details</h1>
        <p>No migration data item found for id "{$item-id}"</p>
      </article>
      {dm:makePageFooter()}
    </body>
  </html>
};

(:~ 
 : Generate migration analysis report
 :)
declare function dm:generateMigrationReport($database as xs:string) as node()* {
  let $topics := migration:getTopics($database)
  let $maps := migration:getMaps($database)
  let $reportData as map(*) := migration:constructMigrationAnalysisReport($database)
  return
  <div class="report-container">
    <h3>General Analysis</h3>
    <table class="report-table">
      <thead>
        <tr>
         <th>Item</th>
         <th>Value</th>
         <th>Notes</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Total Maps</td>
          <td>{count($maps)}</td>
          <td>{$maps ! name(.) => distinct-values() => sort() => string-join(', ')}</td>
        </tr>
        <tr>
          <td>Total Topics</td>
          <td>{count($topics)}</td>
          <td>{$topics ! name(.) => distinct-values() => sort() => string-join(', ')}</td>
        </tr>
      </tbody>
    </table>
    <h3>Topic Migrations</h3>
    <table class="report-table">
      <thead>
        <tr>
         <th>Item</th>
         <th colspan="2">Occurences</th>
         <th>Notes</th>
        </tr>
      </thead>
      <tbody>{
        let $itemsMap as map(*) := $reportData?items
        for $itemId as xs:string in map:keys($itemsMap)
        let $maps as map(*)* := map:get($itemsMap, $itemId)        
        let $itemMap as map(*)? :=
          for $map as map(*) in $maps
          return if ($map('applies-to') = ('topics')) then $map else ()
        let $count as xs:integer? := 
            if (exists($itemMap)) 
            then count($itemMap('items')) 
            else 0
        order by $count descending
        return
        if (exists($itemMap))
        then
          let $migration-item as element(migration-item)? := $itemMap('migration-item')        
          return
            <tr class="{if ($count gt 0) then 'action-required' else 'no-action-required'}">
              <td>{$migration-item/title/node()}</td>
              <td>{$count}</td>
              <td>{
                if ($count gt 0)
                then 
                  <button 
                    form="detail-form"
                    formtarget="migration-details"
                    name="item-id" 
                    value="{$migration-item/@id}">Details</button>
                else ()
              }</td>
              <td>{$migration-item/migrate-to/node()}</td>
            </tr>
        else ()
      }</tbody>
    </table>
    <h3>Map Migrations</h3>
    <table class="report-table">
      <thead>
        <tr>
         <th>Item</th>
         <th colspan="2">Occurences</th>
         <th>Notes</th>
        </tr>
      </thead>
      <tbody>{
        let $itemsMap as map(*) := $reportData?items
        for $itemId as xs:string in map:keys($itemsMap)
        let $maps as map(*)* := map:get($itemsMap, $itemId)        
        let $itemMap as map(*)? :=
          for $map as map(*) in $maps
          return if ($map('applies-to') = ('maps')) then $map else ()
        let $count as xs:integer? := 
            if (exists($itemMap)) 
            then count($itemMap('items')) 
            else 0
        order by $count descending
        return
        if (exists($itemMap))
        then
          let $migration-item as element(migration-item)? := $itemMap('migration-item')        
          return
            <tr class="{if ($count gt 0) then 'action-required' else 'no-action-required'}">
              <td>{$migration-item/title/node()}</td>
              <td>{$count}</td>
              <td>{
                if ($count gt 0)
                then 
                  <button 
                    form="detail-form"
                    formtarget="migration-details"
                    name="item-id" 
                    value="{$migration-item/@id}">Details</button>
                else ()
              }</td>
              <td>{$migration-item/migrate-to/node()}</td>
            </tr>
        else ()
      }</tbody>
    </table>
    <form id="detail-form" action="/dita-migration/migration-detail">
      <input type="hidden" name="database" value="{$database}"/>
    </form>
  </div>
};

(:~ 
 : Handle the case where no database has been selected
 :)
declare function dm:handleNoSelectedDatabase() as node()* {
  let $databases as xs:string* := db:list()
  return
  if (exists($databases))
  then
  <div>
    <h2>Select database with DITA content:</h2>
    <form>
      <fieldset>
        <label for="database">Database</label>
        <select id="database" name="database">{
          for $database in $databases
          order by $database
          return 
          <option value="{$database}">{$database}</option>
        }</select>
      </fieldset>
      <fieldset class="buttons">
        <button type="submit">Analyze</button>    
      </fieldset>
    </form>
  </div>
  else 
  <div>
    <p>Create a database using the BaseX GUI and these settings:</p>
    <p>General tab:</p>
    <ul>
      <li>Set file patterns to `*.xml,*.dita*`</li>
      <li>Turn on <b>Skip corrupt</b></li>
      <li>Turn off <b>Parse files in archives</b></li>
    </ul>
    <p>Parsing tab:</p>
    <ul>
      <li>If you are using DTD-aware parsing, set the following settings:
        <ul>
         <li>Turn on <b>Parse DTDs and entities</b></li>
         <li>Turn on <b>Use XML Catalog file</b> and set the catalog file to the <codeph>catalog-dita.xml</codeph> 
         for the Open Toolkit instance that has the DTDs for your documents installed.</li>
        </ul>
      </li>
      <li>If you are not using DTD-aware parsing, set the following settings:
        <ul>
          <li>Turn on <b>Use internal XML parser</b>.</li>
          <li>All other settings on the Parsing tab should be unchecked.</li>
        </ul>
      </li>            
    </ul>
  </div>

};

(:~ 
 : Constructs the HTML footer for each page
 :)
declare function dm:makePageFooter() as node()* {
  <div class="footer">DITA Migration Analysis Tool <span class="version">Version { migration:getVersionString()}</span></div>
};