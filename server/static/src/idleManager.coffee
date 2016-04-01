define ["jquery", "socketManager",
        "focusManager", "moment"
        "mithril"], ($, socketManager, focusManager, moment, m) ->
  renderUserList = (userList) ->
    userListTag = $('#seen-user-list')
    m.render userListTag.get(0),
      for user, value of userList
        if user != localStorage.displayName
          if value.lastSeen != -1
            lastSeen = moment.utc(value.lastSeen)
            configFun = (element, isInitialized) ->
              if not isInitialized
                $(element).tooltip()
            config = { "data-tooltip": value.status, "data-position": "left", config: configFun }
            m ".chip-wrapper",
              if moment().diff(lastSeen, "minutes") <= 5
                m ".chip.active.tooltipped",
                  config,
                  "#{user}"
              else
                m ".chip.inactive.tooltipped",
                  config,
                  "#{user} #{lastSeen.fromNow()}"

  lastSeen = moment().utc().format()

  $(document).ready () ->
    $(this).mousemove (e) ->
      lastSeen = moment().utc().format()

    $(this).keypress (e) ->
      lastSeen = moment().utc().format()

  socketManager.io.on 'statusChanged', (statuses) ->
    renderUserList(statuses)

  setInterval () ->
    socketManager.io.emit 'status',
      name: localStorage.displayName
      lastSeen: lastSeen
      status: localStorage.status
  , 1000
