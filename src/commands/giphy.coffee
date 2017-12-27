define ["jquery", "arbiter"], ($, arbiter) ->
  (command, args) ->
    if command == "\\g"
      whitespaceRegex = /\s+/
      replacedArgs = args.replace whitespaceRegex, "+"
      xhr = $.get("http://api.giphy.com/v1/gifs/random?tag=" + replacedArgs + "&api_key=dc6zaTOxFJmzC&limit=1")
      xhr.done (data) ->
        text = "<video controls='' loop='' autoplay='' title='#{args}' width='100%' src='#{data.data.image_mp4_url}' class='responsive-video'></video>"
        arbiter.publish "messages/send", { text: text, author: localStorage.displayName }
