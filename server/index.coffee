port = 80
watch = require 'watch'
express = require 'express'
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)
fs = require 'fs'
readline = require 'readline'
socketIOFileUpload = require 'socketio-file-upload'

app.use(express.static(__dirname + '/static'))
socketIOFileUpload.listen app

save = () ->
  fs.writeFile "messages.json", (JSON.stringify exports.messages), (err) ->
    if err
      return console.log err
    console.log "saved"

refresh = ->
  io.sockets.emit 'refresh'

clear = ->
  io.sockets.emit 'clear'
  exports.messages.length = 0
  exports.lastId = -1
  save()

exports.lastId = -1
exports.messages = []
exports.uploadCount = 0
fs.readdir __dirname + '/static/uploads', (err, files) ->
  exports.uploadCount = files.length

if fs.existsSync "messages.json"
  fs.readFile "messages.json", {encoding: "utf8"}, (err, data) ->
    if err then throw err
    exports.messages = JSON.parse data
    exports.lastId = exports.messages.length - 1

io.on 'connection', (socket) ->
  console.log 'http connected'

  uploader = new socketIOFileUpload()
  uploader.dir = __dirname + '/temp'
  uploader.listen socket

  uploader.on 'saved', (e) ->
    console.log e.file.name + " uploaded"
    exports.uploadCount = exports.uploadCount + 1
    newFileName = exports.uploadCount + e.file.name
    newFileName = newFileName.replace /\s+/g, ''
    oldFile = uploader.dir + "/" + e.file.name
    source = fs.createReadStream(uploader.dir + "/" + e.file.name)
    dest = fs.createWriteStream(__dirname + '/static/uploads/' + newFileName)
    source.pipe dest
    exports.lastId = exports.lastId + 1
    messageObj = { text: "the-simmons.dnsalias.net/uploads/" + newFileName }
    io.sockets.emit 'message',
      message: messageObj
      id: exports.lastId
    exports.messages[exports.lastId] = messageObj
    save()

  uploader.on 'error', (e) ->
    console.log "upload error", e

  socket.on 'connected', (lastSeen) ->
    if lastSeen < exports.lastId
      missedMessages = []
      for i in [lastSeen + 1..exports.lastId]
        socket.emit 'message',
              message: exports.messages[i]
              id: i
    if lastSeen > exports.lastId
      socket.emit 'clear'
    socket.emit 'caught up'
    console.log 'client connected'

  socket.on 'refresh', () ->
    refresh()

  socket.on 'message',  (message) ->
    if !exports.lastMessage? or message.text != exports.lastMessage.text
      console.log('message: ' + JSON.stringify(message))
      now = new Date()
      hour = now.getHours()
      if hour == 0
        hour = 12
      if hour > 12
        hour = hour - 12
      minute = "" + now.getMinutes()
      if minute.length == 1
        minute = "0" + minute
      message.time = "#{now.getMonth() + 1}/#{now.getDate()}/#{hour}:#{minute}"
      exports.lastId = exports.lastId + 1
      exports.messages[exports.lastId] = message
      exports.lastMessage = message
      # save every time (probably shorten this when things get crazy)
      save()
      # callback with associated id
      console.log 'message broadcast'
      io.sockets.emit 'message',
          message: message
          id: exports.lastId

  socket.on 'event', (message) ->
    io.sockets.emit 'event', message

  socket.on 'disconnect', ->
    console.log 'http and client disconnected'

http.listen port, ->
  console.log 'listening on *:' + port

rl = readline.createInterface
  input: process.stdin,
  output: process.stdout

rl.resume()
rl.on 'line', (line) ->
  console.log line
  if line == "clear"
    clear()
    console.log 'cleared'
  console.log 'refreshed'
  refresh()
