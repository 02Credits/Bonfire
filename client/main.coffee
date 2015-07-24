app = require 'app'

BrowserWindow = require 'browser-window'
require('crash-reporter').start()

mainWindow = null

app.on 'window-all-closed', ->
  app.quit()

app.on 'ready', ->
  mainWindow = new BrowserWindow {width: 800, height: 600, "node-integration": false}
  mainWindow.loadUrl "http://the-simmons.dnsalias.net"
  mainWindow.on 'closed', ->
    mainWindow = null
