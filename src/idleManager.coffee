define ["jquery", "underscore",
        "pouchdbManager"
        "focusManager", "moment"
        "mithril", "arbiter"], ($, _, PouchDB, focusManager, moment, m, arbiter) ->
  remoteDB = new PouchDB('http://73.193.51.132:5984/statuses')

  render = ->
    remoteDB.allDocs
      include_docs: true
      conflicts: false
      attachments: false
      binary: false
      descending: true
    .then (results) ->
      renderUserList(results.rows)
    .catch (err) ->
      arbiter.publish "error", err

  renderUserList = (userList) ->
    userListTag = $('#seen-user-list')
    m.render userListTag.get(0),
      for user in userList
        user = user.doc
        if user.name != localStorage.displayName
          lastSeen = moment.utc(user.lastSeen)
          lastConnected = moment.utc(user.lastConnected)
          configFun = (element, isInitialized) ->
            rect = element.getBoundingClientRect()
            hiddenElements =  document.elementsFromPoint(rect.left, rect.top)
            if _.any(hiddenElements, (element) -> _.contains(element.classList, "message"))
              $(element).css('opacity', '0.0')
            else
              $(element).css('opacity', '1.0')
            if not isInitialized
              $(element).tooltip()
          config = { "data-tooltip": user.status, "data-position": "left", config: configFun }
          m ".chip-wrapper",
            if moment().diff(lastConnected, "seconds") <= 30
              if moment().diff(lastSeen, "minutes") <= 10
                m ".chip.active.tooltipped",
                  config,
                  "#{user.name}"
              else
                m ".chip.inactive.tooltipped",
                  config,
                  "#{user.name} #{lastSeen.fromNow()}"

  lastSeen = moment()

  $(document).ready () ->
    $(this).mousemove (e) ->
      lastSeen = moment()

    $(this).keypress (e) ->
      lastSeen = moment()

  setInterval () ->
    render()
  , 1000

  setInterval () ->
    remoteDB.upsert(localStorage.displayName, (doc) ->
      doc.name = localStorage.displayName
      doc.lastSeen = lastSeen.utc().valueOf()
      doc.lastConnected = moment().utc().valueOf()
      doc.status = localStorage.status
      doc
    ).catch (err) -> arbiter.publish "error", err
  , 10000
