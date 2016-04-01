define ["jquery",
        "underscore",
        "pouchdb",
        "mithril",
        "moment",
        "pouchdb-collate",
        "pouchdb-search"
        "messageRenderer",
        "inputManager",
        "arbiter",
        "scrollManager"],
($, _, PouchDB, m, moment, collate, search, messageRenderer, inputManager, arbiter, scrollManager) ->
  PouchDB
  .plugin search

  remoteDB = new PouchDB('http://nickelbackfanclub.asuscomm.com:5984/messages')
  localDB = new PouchDB('messages')

  render = () ->
    if !inputManager.searching
      localDB.allDocs
        include_docs: true
        conflicts: false
        attachments: true
        binary: true
        limit: scrollManager.messages
        descending: true
        startkey: "_design"
      .then (results) ->
        renderMessages(results.rows.reverse())
      .catch (err) ->
        alert err

  renderMessages = (messages) ->
    messages = _.filter(messages, (message) ->
      doc = message.doc
      doc.text? and
      doc.author?
    )
    m.render $('#messages').get(0),
      m "div",
        for message in messages
          doc = message.doc
          messageRenderer.render(doc)
    arbiter.publish("messages/rendered")

  arbiter.subscribe "messages/render", (messages) ->
    if !messages?
      render()
    else
      renderMessages messages

  localDB.sync(remoteDB)
  .then () ->
    $('.progress').fadeOut()
    $('#input').prop('disabled', false)
    render()

    localDB.sync remoteDB, {live: true, retry: true}
    .on 'error', (err) ->
      alert err

    localDB.changes
      since: 'now'
      live: true
      include_docs: true
    .on 'change', (change) ->
      render()
      if change.doc.author != localStorage.displayName
        if notifier?
          notifier.notify true
    .on 'error', (err) ->
      console.log err
  .catch (err) ->
    alert err

  arbiter.subscribe "messages/clear", () ->
    remoteDB.allDocs()
    .then (result) ->
      docs = []
      for doc in result.rows
        docs.push
          _id: doc.id
          _rev: doc.value.rev
          _deleted: true
      remoteDB.bulkDocs docs
    .then () ->
      remoteDB.put
        "_id": "0"
        "messageNumber": "0"
        "author": "God"
        "text": "Let there be light..."
    .then () ->
      localDB.destroy()
    .then () ->
      location.reload()
    .catch (err) ->
      console.log err

  arbiter.subscribe "messages/edit", (args) ->
    id = args.id
    text = args.text
    localDB.get(id)
    .then (doc) ->
      doc.text = text
      doc.edited = true
      localDB.put doc
    .catch (err) ->
      console.log err

  arbiter.subscribe "messages/search", (query) ->
    localDB.search
      query: query
      fields: ['author', 'text']
      include_docs: true
    .then (results) ->
      renderMessages(results.rows.reverse())

  arbiter.subscribe "messages/send", (args) ->
    text = args.text
    author = args.author
    if text? and author?
      localDB.allDocs
        include_docs: true
        conflicts: false
        limit: 1
        descending: true
        startkey: "_design"
      .then (results) ->
        doc = results.rows[0].doc
        now = moment().utc()
        time = now.valueOf()
        messageNumber = (parseInt(doc.messageNumber) + 1).toString()
        idNumber = parseInt(messageNumber.toString() + time.toString())
        id = collate.toIndexableString(idNumber).replace(/\u0000/g, '\u0001');
        localDB.put
          "_id": id
          "messageNumber": messageNumber
          "time": time
          "author": author
          "text": text
      .catch (err) -> alert err

  arbiter.subscribe "messages/getLast", (callback) ->
    localDB.query "by_author",
      key: localStorage.displayName;
      limit: 1
      include_docs: true
      descending: true
    .then (result) ->
      callback result.rows[0].doc
    .catch (err) ->
      console.log err

  arbiter.subscribe "messages/get", (args) ->
    id = args.id
    callback = args.callback
    localDB.get(id)
    .then (doc) ->
      callback doc
    .catch (err) ->
      console.log err
