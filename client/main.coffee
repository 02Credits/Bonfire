app = require 'app'
logger = require 'winston'
fs = require 'fs'
path = require 'path'
spawn = require('child_process').spawn
shell = require 'shell'

# Private: Forks to Squirrel in order to install or update our app shortcut on
# the Desktop and in the Start Menu on Windows
#
# finish - A callback to be invoked on completion
#
# Returns Nothing
installShortcuts = (finish) ->
  target = path.basename(process.execPath)
  updateDotExe = path.resolve path.dirname(process.execPath), '..', 'update.exe'
  spawn(updateDotExe, ['--createShortcut', target, '-l Desktop,StartMenu']).on('exit', finish)

# Private: Forks to Squirrel in order to remove our app shortcut on the Desktop
# and in the Start Menu on Windows. Called on app uninstall.
#
# finish - A callback to be invoked on completion
#
# Returns Nothing
uninstallShortcuts = (finish) ->
  target = path.basename(process.execPath)
  updateDotExe = path.resolve path.dirname(process.execPath), '..', 'update.exe'
  spawn(updateDotExe, ['--removeShortcut', target, '-l Desktop,StartMenu']).on('exit', finish)

# Private: When our app is installed, Squirrel (our app install/update framework)
# invokes our executable with specific parameters, usually of the form
# '--squirrel-$EVENT $VERSION' (i.e. '--squirrel-install 0.1.0'). This is our
# chance to do custom install / uninstall actions. Once these events are handled,
# we **must** exit imediately
#
# appStart - A callback to be invoked to start the application if there are no
#            Squirrel events to handle.
#
# Returns Nothing
handleSquirrelEvents = (appStart) ->
  options = process.argv[1..]
  unless options and options.length >= 1
    appStart()
    return

  m = options[0].match /--squirrel-([a-z]+)/
  unless m and m[1]
    appStart()
    return

  if m[1] is 'firstrun'
    appStart()
    return

  app.on 'ready', ->
    switch m[1]
      when 'install' then installShortcuts app.quit
      when 'updated' then installShortcuts app.quit
      when 'uninstall' then uninstallShortcuts app.quit
      when 'obsolete' then app.quit()

appstart = () ->
  BrowserWindow = require 'browser-window'
  require('crash-reporter').start()

  mainWindow = null

  app.on 'window-all-closed', ->
    app.quit()

  app.on 'ready', ->
    logger.info 'ready'
    mainWindow = new BrowserWindow
      width: 800
      height: 600
      "min-width": 640
      "min-height": 480
      "node-integration": false
      icon: __dirname + '/BFicon.png'
      preload: __dirname + '/preload.js'
      title: "Bonfire"
    mainWindow.loadUrl "http://the-simmons.dnsalias.net"
    mainWindow.webContents.on 'new-window', (e, url) ->
      e.preventDefault()
      shell.openExternal url
    mainWindow.on 'closed', ->
      mainWindow = null

updateDotExe = path.resolve path.dirname(process.execPath), '..', 'Update.exe'
if !fs.existsSync updateDotExe
  logger.info "no update.exe"
else
  proc = spawn updateDotExe, ['--update', 'http://02credits.github.io/Bonfire-Releases']
  proc.stdout.on 'data', (m) -> logger.info "Update: " + m
  proc.stderr.on 'data', (m) -> logger.info "Update: " + m

handleSquirrelEvents appstart
