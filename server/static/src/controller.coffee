define ["jquery", "plugins", "focusManager", "userName", "uiSetup"], ($, plugins, focusManager) ->
  window.send = {}
  window.stuck = true

  messagesDiv = $('#messages')
  messagesDiv.scroll ->
    window.stuck = messagesDiv[0].scrollHeight - messagesDiv.scrollTop() == messagesDiv.outerHeight()

  scrollToBottom = ->
    messagesDiv.scrollTop messagesDiv[0].scrollHeight
    window.stuck = true

  sendMessage = () ->
    text = $('input').val()
    text = text.trim()
    if text.length < 500 && text.length != 0
      send { text: $('#input').val(), displayName: $('#name-input').val() }
    localStorage.displayName = $('#name-input').val()
    $('#input').val ''
    scrollToBottom()

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
      scrollIfStuck = ->
        if window.stuck
          scrollToBottom()
      # This is a horrible hack and should be replaced at some point
      for plugin in plugins
        plugin(copy, id)

      elementAtNextIndex = $('div[data-index="#{id + 1}"]')
      if elementAtNextIndex.length != 0
        elementAtNextIndex.before copy.render
      else
        messagesDiv.append copy.render
      # This hack is to allow whatever content was added to be rendered. Works pretty well.
      setTimeout(scrollIfStuck, 100)

  startup: (messages, sendCallback) ->
    window.send = sendCallback
    if messages.length > 50
      for i in [messages.length - 50..messages.length - 1]
        render messages[i], i
    else if messages.length > 0
      for i in [0..messages.length - 1]
        render messages[i], i
    window.stuck = true
  missed: (message, id) ->
    render message, id
  recieved: (message, id) ->
    render message, id
    if window.notifier? and !focusManager.focused
      window.notifier.notify(true)
  event: (message) ->
  connected: ->
  disconnected: ->
