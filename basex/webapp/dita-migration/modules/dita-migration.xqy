(:~ 
 : DITA migration analysis functions
 :
 : Provides functions that analyze DITA content to find and report on
 : items that need to be migrated.
 :)
 
module namespace migration="http://oasis-open.org/dita/modules/dita-migration";

(:~ 
 : Get topics
 :)
declare function migration:getTopics($database) as element()* {
  let $db := db:get($database)
  return
  $db/(topic|concept|task|reference|glossentry)
};