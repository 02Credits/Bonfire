define ["jquery"], ($) ->
  (message) ->
    message.render = "<p class='display-name'>" + $('#name-input').val() + "<\p>" + message.render
