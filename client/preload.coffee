path = require 'path'
fs = require 'fs'
spawn = require('child_process').spawn
logger = require 'winston'

updateDotExe = path.resolve path.dirname(process.execPath), '..', 'update.exe'
if !fs.existsSync updateDotExe
  logger.info "no update.exe"
  return

proc = spawn updateDotExe, ['--update', 'http://02credits.github.io/Bonfire-Updates']
proc.stdout.on 'data', (m) -> logger.info "Update: " + m
proc.stderr.on 'data', (m) -> logger.info "Update: " + m
