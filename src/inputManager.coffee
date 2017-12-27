define ["jquery",
        "underscore",
        "arbiter",
        "chatCommands",
        "emoticons"],
($, _, arbiter, processCommand, emoticons) ->
  exportObject = {}
  input = $('#input')
  hiddenDiv = $(document.createElement('div'))
  hiddenDiv.addClass('hiddendiv')
  $('body').append(hiddenDiv)

  exportObject.editing = false
  exportObject.searching = false
  exportObject.reacting = false
  messageIdToEdit = ""
  messageIdToReact = ""

  sendMessage = () ->
    text = input.text()
    input.text('')
    if text != ""
      commandRegex = /^\\[^\s]+/
      possibleMatch = text.match commandRegex
      if possibleMatch?
        processCommand(possibleMatch[0], text.substring possibleMatch[0].length)
      else if exportObject.editing
        arbiter.publish "messages/edit", {id: messageIdToEdit, text: text}
        input.removeClass "editing"
        exportObject.editing = false
      else if exportObject.reacting
        if emoticons.emoticons[text]?
          arbiter.publish "messages/react", {id: messageIdToReact, emoticon: text}
        else
          Materialize.toast("#{text} isn't an emoticon")
        input.removeClass "reacting"
        exportObject.reacting = false
      else if exportObject.searching
        arbiter.publish "messages/search", text
      else
        lines = [text]
        if not text.startsWith("<")
          lines = text.split("\n")
        for line in lines
          arbiter.publish "messages/send", {text: line, author: localStorage.displayName}
    else
      clear()
  sendMessage = _.throttle(sendMessage, 1000, {trailing: false})

  editDoc = (doc) ->
    input.text(doc.text)
    exportObject.editing = true
    exportObject.searching = false
    exportObject.reacting = false
    input.removeClass "searching"
    input.removeClass "reacting"
    messageIdToEdit = doc._id
    input.addClass "editing"
    input.focus()

  reactDoc = (doc) ->
    input.text ""
    exportObject.reacting = true
    exportObject.editing = false
    exportObject.searching = false
    input.removeClass "searching"
    input.removeClass "editing"
    messageIdToReact = doc._id
    input.addClass "reacting"
    input.focus()

  clear = (e) ->
    if e?
      e.preventDefault()
    exportObject.editing = false
    exportObject.searching = false
    exportObject.reacting = false
    input.removeClass "editing"
    input.removeClass "searching"
    input.removeClass "reacting"
    $('.progress').fadeOut()
    input.text ""
    arbiter.publish("messages/render")

  $(document).keydown (e) ->
    if (e.which == 13 and not e.shiftKey)
      e.preventDefault()
      sendMessage()
    else if (e.which == 40)
      clear(e)
      exportObject.searching = true
      exportObject.editing = false
      input.removeClass "editing"
      input.addClass "searching"
      $('.progress').fadeOut()
      input.focus()
    else if (e.which == 27)
      clear(e)
    else if (e.which == 38)
      arbiter.publish "messages/getLast", editDoc

  if window.openDevTools?
    $('#dev-tools')
      .css("visibility", "visible")
      .click(() -> window.openDevTools())

  arbiter.subscribe "messages/startEdit", (id) ->
    arbiter.publish "messages/get",
      id: id
      callback: (doc) ->
        if doc.author == localStorage.displayName
          editDoc doc

  arbiter.subscribe "messages/startReact", (id) ->
    arbiter.publish "messages/get",
      id: id
      callback: (doc) ->
        if doc.author != localStorage.displayName
          reactDoc doc

  exportObject
