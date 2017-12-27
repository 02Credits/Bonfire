define [
  "pouchdb-search",
  "pouchdb-upsert"
  ],
(search, upsert) ->
  PouchDB.plugin search
  PouchDB.plugin upsert
  PouchDB
