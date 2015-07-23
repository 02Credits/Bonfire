define ->
  (message) ->
    if message.links?
      returnString = ""
      for link in message.links
        fileTypeRegex = /.webm$/
        if fileTypeRegex.test link.href
          returnString = returnString + "<video controls loop width=400px src=\"" + link.href + "\"></video>"
      message.render = message.render + returnString
