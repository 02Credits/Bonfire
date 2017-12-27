define ["pouchdbManager",
        "moment",
        "arbiter"],
(PouchDB, moment, arbiter) ->
  errorDB = new PouchDB('http://73.193.51.132:5984/errors')

  console.log "errorLogger initialized"

  window.onerror = (err) ->
    arbiter.publish "error", err

  arbiter.subscribe "error", (information) ->
    console.log information
    errorDB.put
      "_id": moment().utc().valueOf().toString()
      "user": localStorage.displayName
      "information": information
