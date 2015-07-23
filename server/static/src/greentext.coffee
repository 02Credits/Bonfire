define [], () ->
  (message) ->
    if message.text?
      if message.text[0] == ">"
        message.render = "<div class='greentext'>" + message.render + "</div>"
