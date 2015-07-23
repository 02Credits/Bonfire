define ->
  (message) ->
    if message.text?
      message.render = "<p>" + message.render + "</p>"
