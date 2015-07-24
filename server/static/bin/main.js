// Generated by CoffeeScript 1.9.3
(function() {
  requirejs.config({
    shim: {
      'socketio': {
        exports: 'io'
      },
      'deepCopy': {
        exports: 'owl'
      }
    },
    paths: {
      socketio: '../socket.io/socket.io',
      jquery: '//ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min',
      SocketIOFileUpload: 'siofu.min',
      deepCopy: 'deepCopy'
    }
  });

  requirejs(['socketio', 'controller', 'SocketIOFileUpload', 'deepCopy'], function(io, controller, siofu, deepCopy) {
    var fileUploader, send, socket;
    socket = io();
    fileUploader = new siofu(socket);
    fileUploader.listenOnDrop(document);
    window.messages = [];
    if (localStorage.messages != null) {
      window.messages = JSON.parse(localStorage.messages);
    }
    window.caughtup = false;
    window.fileUpload = {};
    send = function(message) {
      return socket.emit('message', message);
    };
    controller.startup(window.messages, send);
    socket.on('disconnect', function() {
      controller.disconnected();
      return window.caughtUp = false;
    });
    return socket.on('connect', function() {
      controller.connected();
      socket.emit('connected', window.messages.length - 1);
      socket.on('refresh', function() {
        return location.reload();
      });
      socket.on('clear', function() {
        localStorage.messages = "[]";
        window.messages = [];
        return location.reload();
      });
      socket.on('message', function(data) {
        window.messages[data.id] = deepCopy.deepCopy(data.message, 5);
        localStorage.messages = JSON.stringify(window.messages);
        if (window.caughtUp) {
          return controller.recieved(data.message, data.id);
        } else {
          return controller.missed(data.message, data.id);
        }
      });
      socket.on('event', function(message) {
        return controller.event(message);
      });
      return socket.on('caught up', function() {
        return window.caughtUp = true;
      });
    });
  });

}).call(this);
