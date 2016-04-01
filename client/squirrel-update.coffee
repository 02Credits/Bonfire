ChildProcess = require 'child_process'
fs = require 'fs'
path = require 'path'

updateDotExe = path.resolve path.dirname(process.execPath), '..', 'update.exe'
exeName = path.basename(process.execPath)

spawn = (command, args, callback) ->
  stdout = ''

  try
    spawnedProcess = ChildProcess.spawn(command, args)
  catch error
    # Spawn can throw an error
    process.nextTick -> callback?(error, stdout)
    return

  spawnedProcess.stdout.on 'data', (data) -> stdout += data

  error = null
  spawnedProcess.on 'error', (processError) -> error ?= processError
  spawnedProcess.on 'close', (code, signal) ->
    error ?= new Error("Command failed: #{signal ? code}") if code isnt 0
    error?.code ?= code
    error?.stdout ?= stdout
    callback?(error, stdout)

spawnUpdate = (args, callback) ->
  spawn(updateDotExe, args, callback)

createShortcuts = (callback) ->
  spawnUpdate(['--createShortcut', exeName], callback)

updateShortcuts = (callback) ->
  if homeDirectory = fs.getHomeDirectory()
    desktopShortcutPath = path.join(homeDirectory, 'Desktop', 'Bonfire.lnk')
    # Check if the desktop shortcut has been previously deleted and
    # and keep it deleted if it was
    fs.exists desktopShortcutPath, (desktopShortcutExists) ->
      createShortcuts ->
        if desktopShortcutExists
          callback()
        else
          # Remove the unwanted desktop shortcut that was recreated
          fs.unlink(desktopShortcutPath, callback)
  else
    createShortcuts(callback)

removeShortcuts = (callback) ->
  spawnUpdate(['--removeShortcut', exeName], callback)

exports.handleStartupEvent = (app, squirrelCommand) ->
  console.log "handling startup event"
  switch squirrelCommand
    when '--squirrel-install'
      console.log "creating shortcuts"
      createShortcuts ->
        app.quit()
      true
    when '--squirrel-updated'
      updateShortcuts ->
        app.quit()
      true
    when '--squirrel-uninstall'
      console.log "removing shortcuts"
      removeShortcuts ->
        app.quit()
      true
    when '--squirrel-obsolete'
      app.quit()
      true
    else
      console.log "no event to handle"
      false
