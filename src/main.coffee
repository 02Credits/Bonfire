installShortcuts = (finish) ->
  target = path.basename(process.execPath)
  updateDotExe = path.resolve path.dirname(process.execPath), '..', 'update.exe'
  spawn(updateDotExe, ['--createShortcut', target]).on('exit', finish)

uninstallShortcuts = (finish) ->
  target = path.basename(process.execPath)
  updateDotExe = path.resolve path.dirname(process.execPath), '..', 'update.exe'
  spawn(updateDotExe, ['--removeShortcut', target]).on('exit', finish)

handleSquirrelEvents = (appstart) ->
  options = process.argv[1..]
  unless options and options.length >= 1
    appstart()
    return

  m = options[0].match /--squirrel-([a-z]+)/
  unless m and m[1]
    appstart()
    return

  if m[1] is 'firstrun'
    appstart()
    return

  app.on 'ready', ->
    switch m[1]
      when 'install' then installShortcuts app.quit
      when 'updated' then installShortcuts app.quit
      when 'uninstall' then uninstallShortcuts app.quit
      when 'obsolete' then app.quit()

handleSquirrelEvents ->
  app = require 'app'
  BrowserWindow = require 'browser-window'
  require('crash-reporter').start()

  mainWindow = null

  app.on 'window-all-closed', ->
    app.quit()

  app.on 'ready', ->
    mainWindow = new BrowserWindow {width: 800, height: 600}
    mainWindow.loadUrl 'file://#{__dirname}/index.html'
    mainWindow.on 'closed', ->
      mainWindow = null
