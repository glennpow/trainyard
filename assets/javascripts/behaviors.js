Event.addBehavior.reassignAfterAjax = true;
Event.addBehavior({
  'div.paginate .links a' : Remote.Link,
	'div.paginate div.index-search form' : Remote.Form,
  '.indexer-th a' : Remote.Link
})