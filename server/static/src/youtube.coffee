define ->
  (message) ->
    if message.links?
      returnString = ""
      for link in message.links
        fileTypeRegex = /^https:\/\/www\.youtube\.com\/watch\?v=/g

        if fileTypeRegex.test link.href
          youtubeId = link.href.replace fileTypeRegex, ''
          returnString = returnString + "<iframe width=\"560px\" height=\"315\" src=\"http://www.youtube.com/embed/" + youtubeId + "\" frameborder=\"0\" allowfullscreen></iframe>"
      message.render = message.render + returnString
