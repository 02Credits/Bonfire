path = require 'path'
fs = require 'fs'

Rx.Observable.timer(0, 6*60*60*1000).subscribe ->
  updateDotExe = path.resolve path.dirname(process.execPath), '..', 'update.exe'
  return unless fs.existsSync(updateDotExe)

  proc = spawn updateDotExe, ['--update', 'http://02credits.com/bonfirereleases/']
  proc.stdout.on 'data', (m) -> logger.info("Update: " + m)

socket = io.connect('http://the-simmons.dnsalias.net')
socket.on 'message', (msg) ->
  document.body.innerHTML += '<p>' + msg + '<p>'
