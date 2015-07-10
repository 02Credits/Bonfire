express = require('express')
app = express()

app.use express.static(__dirname + '/client')

app.listen 80, ->
  console.log 'listening on *:80'
