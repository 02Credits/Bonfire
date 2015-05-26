var app = require('app');
var dialog = require('dialog');

var handleStartupEvent = () => {
    let squirrelCommand = process.argv[1];
    switch (squirrelCommand) {
    case '--squirrel-install':
    case '--squirrel-updated':
        dialog.showMessageBox({ message: "updated" });
        app.quit();
        return false;
    case '--squirrel-uninstall':
        dialog.showMessageBox({ message: "uninstall" });
        app.quit();
        return false;
    case '--squirrel-obsolete':
        dialog.showMessageBox({ message: "obsolete" });
        app.quit();
        return false;
    default:
        return true;
    }
};

if (handleStartupEvent()) {
    var BrowserWindow = require('browser-window');
    require('crash-reporter').start();

    var mainWindow = null;

    app.on('window-all-closed', () => {
        app.quit();
    });

    app.on('ready', () => {
        mainWindow = new BrowserWindow({width: 800, height: 600});

        mainWindow.loadUrl('file://' + __dirname + '/index.html');

        mainWindow.on('closed', () => {
            mainWindow = null;
        });
    });
}
