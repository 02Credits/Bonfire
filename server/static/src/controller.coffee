define ["jquery", "plugins", "focusManager", "chatCommands", "scrollManager", "userName", "uiSetup"], ($, plugins, focusManager, chatCommands, scrollManager) ->
  window.send = {}
  window.stuck = true
  window.baseTitle = "Bonfire"

  messagesDiv = $('#messages')
  scrollManager.setup messagesDiv

  sendMessage = () ->
    text = $('input').val()
    text = text.trim()
    chatCommands text
    if text.length < 500 && text.length != 0
      scrollManager.stuck = true
      send
        text: $('#input').val()
        displayName: $('#name-input').val()
    localStorage.displayName = $('#name-input').val()
    $('#input').val ''

  $('#input').keydown (e) ->
    if (e.which == 13)
      e.preventDefault()
      sendMessage()
  $('#send').click (e) ->
    sendMessage()
  $('#input').focus()

  render = (message, id) ->
    if message?
      copy = JSON.parse JSON.stringify message
      # This is a horrible hack and should be replaced at some point
      for plugin in plugins
        plugin(copy, id)
      elementAtNextIndex = $('div[data-index="#{id}"]')
        messagesDiv.append copy.render

  startup: (sendCallback) ->
    window.send = sendCallback
    window.stuck = true
  recieved: (message, id) ->
    render message, id
    if window.notifier? and !focusManager.focused
      window.notifier.notify(true)
  event: (message) ->
  connected: (messages) ->
    if messages.length > 50
      for i in [messages.length - 50..messages.length - 1]
        render messages[i], i
    else if messages.length > 0
      for i in [0..messages.length - 1]
        render messages[i], i
  disconnected: ->
