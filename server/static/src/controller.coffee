define ["jquery", "plugins"], ($, plugins) ->
  window.send = {}
  window.stuck = true

  messagesDiv = $('#messages')
  messagesDiv.scroll ->
    window.stuck = messagesDiv[0].scrollHeight - messagesDiv.scrollTop() == messagesDiv.outerHeight()

  scrollToBottom = ->
    messagesDiv.scrollTop messagesDiv[0].scrollHeight

  $('#input').keydown (e) ->
    if (e.which == 13)
      e.preventDefault()
      text = $('input').val()
      text = text.trim()
      if text.length < 500 && text.length != 0
        send { text: $('#input').val(), displayName: $('#name-input').val() }
      localStorage.displayName = $('#name-input').val()
      $('#input').val ''
  $('#input').focus()

  if localStorage.displayName?
    $('#name-input').val localStorage.displayName
  else
    $('#name-input').val "Village Idiot"

  render = (message, id) ->
    # This is a horrible hack and should be replaced at some point
    for plugin in plugins
      plugin(message)
    messagesDiv.append message.render
    scrollIfStuck = ->
      if window.stuck
        scrollToBottom()
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
  event: (message) ->
  connected: ->
  disconnected: ->
