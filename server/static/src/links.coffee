define ["linkify-string", "linkify"], (linkifyStr, linkify) ->
  (message) ->
    if message.text?
      message.links = linkify.find message.text
      message.render = linkifyStr message.text
      message
