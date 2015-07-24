define ["jquery"], ($) ->
  (message) ->
    if message.displayName
      message.render = "<p class='display-name'>" + message.displayName + "<\p>" + message.render
