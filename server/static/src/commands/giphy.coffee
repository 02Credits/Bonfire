define ["jquery"], ($) ->
  (command, args) ->
    obj = {}
    obj.args = args
    if args == ""
      obj.args = window.messages[window.message.length - 1].text
    if command == "/giphy"
      whitespaceRegex = /\s+/
      replacedArgs = obj.args.replace whitespaceRegex, "+"
      xhr = $.get("http://api.giphy.com/v1/gifs/search?q=" + replacedArgs + "&api_key=dc6zaTOxFJmzC&limit=1")
      xhr.done (data) ->
        message = { text: data.data[0].images.fixed_height.url }
        window.send message
    else if command == "/g"
      whitespaceRegex = /\s+/
      replacedArgs = obj.args.replace whitespaceRegex, "+"
      xhr = $.get("http://api.giphy.com/v1/gifs/translate?s=" + replacedArgs + "&api_key=dc6zaTOxFJmzC")
      xhr.done (data) ->
        message = { text: data.data.images.fixed_height.url }
        window.send message
