define ["socketio", "arbiter"], (io, arbiter) ->
  socket = io()
  socket.on 'disconnect', ->
    window.caughtUp = false

  socket.on 'connect', ->
    socket.emit 'connected'

  socket.on 'refresh', ->
    location.reload()

  io: socket
