define ->
  (message) ->
    if message.links?
      returnString = ""
      for link in message.links
        fileTypeRegex = /.(?:jpg|gif|png|jpeg|JPG|GIF|PNG|JPEG)$/
        if fileTypeRegex.test link.href
          returnString = returnString + "<img src=\"" + link.href + "\" width=400px>"
      message.render = message.render + returnString
