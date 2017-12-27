import { app, BrowserWindow } from 'electron'
import * as express from 'express'
import * as path from 'path'

let debug = false
for (let arg of process.argv) {
  if (arg === '-d' || arg === '--dev') {
    debug = true
  }
}

let mainWindow: Electron.BrowserWindow

function onReady() {
  if (!debug) {
    let expressApp = express()
    expressApp.set('port', 11337)
    expressApp.use(express.static(path.join(__dirname, '..')))
    expressApp.listen(expressApp.get('port'))
  }

  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      experimentalFeatures: true
    }
  })

  if (!debug) {
    mainWindow.loadURL('http://localhost:11337/bin/index.html')
    mainWindow.setMenu(null as any);
  } else {
    mainWindow.loadURL('http://localhost:8080/bin/index.html')
  }
  mainWindow.on('close', app.quit)
}

app.on('ready', onReady)
app.on('window-all-closed', app.quit)
