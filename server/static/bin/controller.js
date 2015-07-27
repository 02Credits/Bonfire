// Generated by CoffeeScript 1.9.3
(function() {
  define(["jquery", "plugins"], function($, plugins) {
    var messagesDiv, render, scrollToBottom, sendMessage;
    window.send = {};
    window.stuck = true;
    messagesDiv = $('#messages');
    messagesDiv.scroll(function() {
      return window.stuck = messagesDiv[0].scrollHeight - messagesDiv.scrollTop() === messagesDiv.outerHeight();
    });
    scrollToBottom = function() {
      messagesDiv.scrollTop(messagesDiv[0].scrollHeight);
      return window.stuck = true;
    };
    sendMessage = function() {
      var text;
      text = $('input').val();
      text = text.trim();
      if (text.length < 500 && text.length !== 0) {
        send({
          text: $('#input').val(),
          displayName: $('#name-input').val()
        });
      }
      localStorage.displayName = $('#name-input').val();
      $('#input').val('');
      return scrollToBottom();
    };
    $('#input').keydown(function(e) {
      if (e.which === 13) {
        e.preventDefault();
        return sendMessage();
      }
    });
    $('#send').click(function(e) {
      return sendMessage();
    });
    $('#input').focus();
    if (localStorage.displayName != null) {
      $('#name-input').val(localStorage.displayName);
    } else {
      $('#name-input').val("Village Idiot");
    }
    $(document).ready(function() {
      return $('.modal-trigger').leanModal();
    });
    render = function(message, id) {
      var copy, elementAtNextIndex, j, len, plugin, scrollIfStuck;
      if (message != null) {
        copy = JSON.parse(JSON.stringify(message));
        scrollIfStuck = function() {
          if (window.stuck) {
            return scrollToBottom();
          }
        };
        for (j = 0, len = plugins.length; j < len; j++) {
          plugin = plugins[j];
          plugin(copy, id);
        }
        elementAtNextIndex = $('div[data-index="#{id + 1}"]');
        if (elementAtNextIndex.length !== 0) {
          elementAtNextIndex.before(copy.render);
        } else {
          messagesDiv.append(copy.render);
        }
        setTimeout(scrollIfStuck, 100);
        return setTimeout(scrollIfStuck, 1000);
      }
    };
    return {
      startup: function(messages, sendCallback) {
        var i, j, k, ref, ref1, ref2;
        window.send = sendCallback;
        if (messages.length > 50) {
          for (i = j = ref = messages.length - 50, ref1 = messages.length - 1; ref <= ref1 ? j <= ref1 : j >= ref1; i = ref <= ref1 ? ++j : --j) {
            render(messages[i], i);
          }
        } else if (messages.length > 0) {
          for (i = k = 0, ref2 = messages.length - 1; 0 <= ref2 ? k <= ref2 : k >= ref2; i = 0 <= ref2 ? ++k : --k) {
            render(messages[i], i);
          }
        }
        return window.stuck = true;
      },
      missed: function(message, id) {
        return render(message, id);
      },
      recieved: function(message, id) {
        return render(message, id);
      },
      event: function(message) {},
      connected: function() {},
      disconnected: function() {}
    };
  });

}).call(this);
