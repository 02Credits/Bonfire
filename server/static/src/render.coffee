define [], () ->
  (message) ->
    if message.text?
      message.render = "<div><div class='message'>" + message.render + "<div><div>"
