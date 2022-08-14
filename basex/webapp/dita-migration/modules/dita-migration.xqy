(:~ 
 : DITA migration analysis functions
 :
 : Provides functions that analyze DITA content to find and report on
 : items that need to be migrated.
 :)
 
module namespace migration="http://oasis-open.org/dita/modules/dita-migration";

declare variable $migration:migrationData as element()? :=
   doc('../resource/migration-analysis-data.xml')/*;

(:~ 
 : Get all the topics in the specified database
 :)
declare function migration:getTopics($database) as element()* {
  let $db := db:get($database)
  return
  $db/(topic|concept|task|reference|glossentry)
};

(:~ 
 : Get all the maps in the specified database
 :)
declare function migration:getMaps($database) as element()* {
  let $db := db:get($database)
  return
  $db/*[ends-with(db:path(.), '.ditamap')]
};

(:~ 
 : Construct migration analysis report data
 : @param database The database to analyze
 : @return XML data with the migration analysis results
 :)
declare function migration:constructMigrationAnalysisReport($database as xs:string) 
  as map(*) {
  let $maps as element()* := migration:getMaps($database)
  let $topics as element()* := migration:getTopics($database)
  (: let $debug := (prof:dump('migration data'), prof:dump($migration:migrationData)) :)
  let $items as map(*) := map:merge(
    for $migrationItem as element() in $migration:migrationData/*
      (: let $debug := (prof:dump('migrationitem'), prof:dump($migrationItem)) :)
      let $appliesTo as xs:string* := $migrationItem/applies-to ! tokenize(., '\s+')
      let $context as item()* :=
       (if ($appliesTo = ('maps')) then $maps else (),
        if ($appliesTo = ('topics')) then $topics else ()
       )
      let $expression as xs:string := $migrationItem/xpath ! string(.)
      let $items as item()* := 
         try {
          migration:evaluateExpression($context, $expression)    
        } catch * {
          prof:dump(' migration:constructMigrationAnalysisReport(): ' || $err:description)
        }
      return map{
        string($migrationItem/@id) :
        map {
          'items' : $items
        }
      }
    )
  
  let $result := map:merge(
    (map{ 'timestamp' : current-dateTime()},
     map{ 'items' : $items }
    )
  )
  return $result
  
};

(:~ 
 : Evaluate XQuery expression
 : @param context Context nodes for the expression
 : @param expression Expression to be evaluated
 : @return Zero or more items
 :)
declare function migration:evaluateExpression(
  $context as node()+,
  $expression as xs:string) as item()* {
  (: let $debug := prof:dump('migration:evaluateExpression(): Expression: "' || $expression || '"') :)
  
  let $query as xs:string :=
  ``[
    let $result as item()* := (.)`{$expression}`
    return $result
  ]``
  
  let $result as item()* := xquery:eval(
    $query, 
    map{ '' : $context}
  )
  return $result
}; 