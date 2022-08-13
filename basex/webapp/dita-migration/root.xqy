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
         <th>Value</th>
         <th>Notes</th>
        </tr>
      </thead>
      <tbody>{
        let $count as xs:integer := count($topics//titlealts)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlelement">titlealts</span> in topics</td>
          <td>{$count}</td>
          <td><span class="xmlelement">titlealts</span> has been removed. 
          Move alternative titles into the topic prolog.</td>
        </tr>,
        let $count as xs:integer := count($topics//hazardstatement[.//hazardsymbol])
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlelement">hazardstatement</span> with with <span class="xmlelement">hazardsymbol</span></td>
          <td>{$count}</td>
          <td>Move <span class="xmlelement">hazardsymbol</span> into <span class="xmlelement">messagepanel</span> .</td>
        </tr>,
        let $count as xs:integer := count($topics//longquote[@href | @scope | @format])
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlelement">longquote</span> with removed linking attributes</td>
          <td>{$count}</td>
          <td>Remove <span class="xmlatt">href</span>, <span class="xmlatt">scope</span>, and <span class="xmlatt">format</span> attributes.</td>
        </tr>,
        let $count as xs:integer := count($topics//index-base)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlelement">index-base</span></td>
          <td>{$count}</td>
          <td>Remove <span class="xmlelement">index-base</span> elements.</td>
        </tr>,
        let $count as xs:integer := count($topics//index-sort-as)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlelement">index-sort-as</span></td>
          <td>{$count}</td>
          <td>Replace <span class="xmlelement">index-sort-as</span> with <span class="xmlelement">sort-as</span>.</td>
        </tr>,
        let $count as xs:integer := count($topics//@spectitle)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlatt">spectitle</span></td>
          <td>{$count}</td>
          <td>Replace <span class="xmlatt">spectitle</span> with appropriate <span class="xmlatt">outputclass</span> value  .</td>
        </tr>,
        let $count as xs:integer := count($topics//stentry[@specentry])
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">

          <td><span class="xmlelement">stentry</span> with <span class="xmlatt">specentry</span></td>
          <td>{$count}</td>
          <td>Replace <span class="xmlatt">specentry</span> with appropriate <span class="xmlatt">outputclass</span> value  .</td>
        </tr>,
        let $count as xs:integer := count($topics//substeps)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">

          <td><span class="xmlelement">substeps</span> elements</td>
          <td>{$count}</td>
          <td>Replace <span class="xmlelement">substeps</span> with <span class="xmlelement">steps</span>.</td>
        </tr>,
        let $count as xs:integer := count($topics//object[@declare | @classid | @classidkeyref | @codebase | @codebasekeyref | 
                                     @archive | @archivekeyrefs | @standby])
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">

          <td><span class="xmlelement">object</span> with removed object attributes</td>
          <td>{$count}</td>
          <td>Remove the attributes.</td>
        </tr>,
        let $count as xs:integer := count($topics//object/param[@type | @valuetype])
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">

          <td><span class="xmlelement">param</span> with removed param attributes</td>
          <td>{$count}</td>
          <td>Remove the attributes.</td>
        </tr>,
        let $count as xs:integer := count($topics//longquoteref)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">

          <td><span class="xmlelement">longquoteref</span></td>
          <td>{$count}</td>
          <td>Replace with <span class="xmlelement">xref</span>.</td>
        </tr>,
        let $count as xs:integer := count($topics//sectiondiv)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">

          <td><span class="xmlelement">sectiondiv</span></td>
          <td>{$count}</td>
          <td>Replace with <span class="xmlelement">div</span>.</td>
        </tr>,
        let $count as xs:integer := count($topics//linktext)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">

          <td><span class="xmlelement">linktext</span></td>
          <td>{$count}</td>
          <td>Replace with <span class="xmlelement">keytext</span>.</td>
        </tr>,
        let $count as xs:integer := count($topics//boolean)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">

          <td><span class="xmlelement">boolean</span></td>
          <td>{$count}</td>
          <td>Replace with appropriate text or other element.</td>
        </tr>,
        let $count as xs:integer := count($topics//data-about)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">

          <td><span class="xmlelement">data-about</span></td>
          <td>{$count}</td>
          <td>Remove element or replace with appropriate use of <span class="xmlelement">data</span></td>
        </tr>,
        let $count as xs:integer := count($topics//indextermref)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">

          <td><span class="xmlelement">indextermref</span></td>
          <td>{$count}</td>
          <td>Remove element.</td>
        </tr>,
        let $count as xs:integer := count($topics//itemgroup)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">

          <td><span class="xmlelement">itemgroup</span></td>
          <td>{$count}</td>
          <td>Split containing list into two lists.</td>
        </tr>,
        let $count as xs:integer := count($topics//image[@alt])
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">

          <td><span class="xmlatt">alt</span></td>
          <td>{$count}</td>
          <td>Replace with <span class="xmlelement">alt</span> within <span class="xmlelement">image</span> or 
          <span class="xmlelement">keytext</span> within <span class="xmlelement">keydef</span> for the image&apos;s key.</td>
        </tr>,
        let $count as xs:integer := count($topics//image[@longdescref])
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">

          <td><span class="xmlatt">longdescref</span></td>
          <td>{$count}</td>
          <td>Remove the attribute.</td>
        </tr>,
        let $count as xs:integer := count($topics//*[@collectiontype eq 'tree'])
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">

          <td><span class="xmlatt">collectiontype</span> of "tree"</td>
          <td>{$count}</td>
          <td>Remove the attribute or select a different value.</td>
        </tr>,
        let $count as xs:integer := count($topics//@print)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">

          <td><span class="xmlatt">print</span></td>
          <td>{$count}</td>
          <td>Replace with <span class="xmlatt">deliveryTarget</span> with appropriate values (i.e., "pdf").</td>
        </tr>,
        let $count as xs:integer := count($topics//@query)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">

          <td><span class="xmlatt">query</span></td>
          <td>{$count}</td>
          <td>Remove the attribute.</td>
        </tr>,
        let $count as xs:integer := count($topics//lq[@type])
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">

          <td><span class="xmlatt">type</span> on  <span class="xmlelement">lq</span></td>
          <td>{$count}</td>
          <td>Remove the attribute.</td>
        </tr>,
        let $count as xs:integer := count($topics//@role[. = ('sample', 'external')])
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">

          <td><span class="xmlatt">role</span> "sample" or "external"</td>
          <td>{$count}</td>
          <td>Remove the attribute or select a different role.</td>
        </tr>
    }</tbody>
    </table>
    <h3>Map Migrations</h3>
    <table class="report-table">
      <thead>
        <tr>
         <th>Item</th>
         <th>Value</th>
         <th>Notes</th>
        </tr>
      </thead>
      <tbody>{
        let $count as xs:integer := count($maps//titlealts)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlelement">titlealts</span></td>
          <td>{$count}</td>
          <td><span class="xmlelement">titlealts</span> has been removed. 
          Move alternative titles into <span class="xmlelement">topicmeta</span>.</td>
        </tr>,
        let $count as xs:integer := count($maps//@navtitle)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlatt">navtitle</span></td>
          <td>{$count}</td>
          <td>Replace with <span class="xmlelement">navtitle</span> in <span class="xmlelement">topicmeta</span>.</td>
        </tr>,
        let $count as xs:integer := count($maps//@title)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlatt">title</span></td>
          <td>{$count}</td>
          <td>Replace with <span class="xmlelement">title</span>.</td>
        </tr>,
        let $count as xs:integer := count($maps//@copy-to)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlatt">copy-to</span></td>
          <td>{$count}</td>
          <td>Replace with <span class="xmlelement">resourceid</span> in <span class="xmlelement">topicmeta</span> or with
          a processor-defined equivalent.</td>
        </tr>,
        let $count as xs:integer := count($maps//@chunk)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlatt">chunk</span></td>
          <td>{$count}</td>
          <td>Values: {$maps//@chunk ! string(.) => distinct-values() => sort() => string-join(', ')}
          <p>Replace with "combine" or "split" as appropriate.</p></td>
        </tr>,
        let $count as xs:integer := count($maps//topicset)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlelement">topicset</span></td>
          <td>{$count}</td>
          <td><span class="xmlelement">topicset</span> has been removed. 
         </td>
        </tr>,
        let $count as xs:integer := count($maps//topicsetref)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlelement">topicsetref</span></td>
          <td>{$count}</td>
          <td><span class="xmlelement">topicsetref</span> has been removed. 
         </td>
        </tr>,
        let $count as xs:integer := count($maps//anchor)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlelement">anchor</span></td>
          <td>{$count}</td>
          <td><span class="xmlelement">anchor</span> has been removed. 
         </td>
        </tr>,
        let $count as xs:integer := count($maps//anchorref)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlelement">anchorref</span></td>
          <td>{$count}</td>
          <td><span class="xmlelement">anchorref</span> has been removed. 
         </td>
        </tr>,
        let $count as xs:integer := count($maps//linktext)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlelement">linktext</span></td>
          <td>{$count}</td>
          <td>Replace with <span class="xmlelement">keytext</span>.</td>
        </tr>,
        let $count as xs:integer := count($maps//reltable[@collectiontype ]|$maps//relcolspec[@collectiontype ])
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlatt">collectiontype</span> on <span class="xmlelement">reltable</span> and
          <span class="xmlelement">relcolspec</span></td>
          <td>{$count}</td>
          <td>Remove the attribute.</td>
        </tr>,
        let $count as xs:integer := count($maps//navref[@keyref])
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlatt">keyref</span> on <span class="xmlelement">navref</span></td>
          <td>{$count}</td>
          <td>Remove the attribute or replace with <span class="xmlatt">href</span>.</td>
        </tr>,
        let $count as xs:integer := count($maps//topichead[@locktitle]|$maps//topicgroup[@locktitle])
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlatt">locktitle</span> on <span class="xmlelement">topichead</span> and <span class="xmlelement">topicgroup</span></td>
          <td>{$count}</td>
          <td>Remove the attribute.</td>
        </tr>,
        let $count as xs:integer := count($maps//metdata[@mapkeyref])
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlatt">mapkeyref</span> on <span class="xmlelement">metadata</span></td>
          <td>{$count}</td>
          <td>Remove the attribute.</td>
        </tr>,
        let $count as xs:integer := count($maps//@print)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlatt">print</span></td>
          <td>{$count}</td>
          <td>Replace with <span class="xmlatt">deliveryTarget</span> with appropriate values (i.e., "pdf").</td>
        </tr>,
        let $count as xs:integer := count($maps//@query)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlatt">query</span></td>
          <td>{$count}</td>
          <td>Remove the attribute.</td>
        </tr>,
        let $count as xs:integer := count($maps//@lockmeta)
        return
        <tr class="{if ($count gt 0) then 'action-required' else 'no-hits'}">
          <td><span class="xmlatt">lockmeta</span></td>
          <td>{$count}</td>
          <td>Remove the attribute.</td>
        </tr>
      }</tbody>
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