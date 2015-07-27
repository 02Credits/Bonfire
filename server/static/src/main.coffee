requirejs.config
  shim:
    'socketio':
      exports: 'io'
    'deepCopy':
      exports: 'owl'
    'uuid':
      exports: 'uuid'
    'materialize':
      deps: ['jquery']
  paths:
    socketio: '../socket.io/socket.io'
    jquery: '//ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min'
    SocketIOFileUpload: 'siofu.min'
    materialize: 'materialize.amd.min'
requirejs ['socketio', 'controller', 'SocketIOFileUpload', 'materialize'], (io, controller, siofu, deepCopy) ->
  socket = io()
  fileUploader = new siofu socket
  fileUploader.listenOnDrop document
  window.messages = []
  # Local variables
  if localStorage.messages?
    window.messages = JSON.parse localStorage.messages
  window.caughtup = false
  window.fileUpload = {}

  send = (message) ->
    socket.emit 'message', message

  controller.startup(window.messages, send)

  socket.on 'disconnect', ->
    controller.disconnected()
    window.caughtUp = false

  socket.on 'connect', ->
    controller.connected()
    socket.emit 'connected', window.messages.length - 1

    socket.on 'refresh', ->
      location.reload()

    socket.on 'clear', ->
      localStorage.messages = "[]"
      window.messages = []
      location.reload()

    socket.on 'message', (data) ->
      if !window.messages[data.id]?
        window.messages[data.id] = data.message
        localStorage.messages = JSON.stringify window.messages
        if window.caughtUp
          controller.recieved data.message, data.id
        else
          controller.missed data.message, data.id

    socket.on 'event', (message) ->
      controller.event message

    socket.on 'caught up', ->
      window.caughtUp = true
