// Generated by CoffeeScript 1.12.0
(function() {
  define(["socketio", "arbiter"], function(io, arbiter) {
    var socket;
    socket = io();
    socket.on('disconnect', function() {
      return window.caughtUp = false;
    });
    socket.on('connect', function() {
      return socket.emit('connected');
    });
    socket.on('refresh', function() {
      return location.reload();
    });
    return {
      io: socket
    };
  });

}).call(this);
