// Generated by CoffeeScript 1.9.3
(function() {
  define(["jquery"], function($) {
    return function(message) {
      if (message.displayName) {
        return message.render = "<p class='display-name'>" + message.displayName + "<\p>" + message.render;
      }
    };
  });

}).call(this);