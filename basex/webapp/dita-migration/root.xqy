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
      <title>DITA Migration Tool</title>
      <link href="/static/dita-migration.css" type="text/css" rel="stylesheet"/>
    </head>
    <body>
      <h1>DITA Migration Tool</h1>
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
    </body>
  </html>
};

(:~ 
 : Generate migration analysis report
 :)
declare function dm:generateMigrationReport($database as xs:string) as node()* {
  let $topics := migration:getTopics($database)
  let $maps := migration:getMaps($database)
  return
  <div class="report-container">
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