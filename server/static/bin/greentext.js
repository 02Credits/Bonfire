// Generated by CoffeeScript 1.9.3
(function() {
  define([], function() {
    return function(message) {
      if (message.text != null) {
        if (message.text[0] === ">") {
          return message.render = "<div class='greentext'>" + message.render + "</div>";
        }
      }
    };
  });

}).call(this);