define ["jquery",
        "underscore",
        "arbiter"],
($, _, arbiter) ->
  exportObject = {}
  input = $('#input')
  sendButton = $('#send')

  exportObject.editing = false
  exportObject.searching = false
  messageIdToEdit = ""

  sendMessage = () ->
    text = input.val()
    input.val('')

    if text != ""
      if exportObject.editing
        arbiter.publish "messages/edit", {id: messageIdToEdit, text: text}
        input.removeClass "editing"
      else if exportObject.searching
        arbiter.publish "messages/search", text
      else
        arbiter.publish "messages/send", {text: text, author: localStorage.displayName}
      exportObject.editing = false
    else
      clear()
  sendMessage = _.throttle(sendMessage, 1000, {trailing: false})

  editDoc = (doc) ->
    input.val(doc.text)
    exportObject.editing = true
    exportObject.searching = false
    input.removeClass "searching"
    messageIdToEdit = doc._id
    input.addClass "editing"
    input.focus()

  clear = (e) ->
    if e?
      e.preventDefault()
    exportObject.editing = false
    exportObject.searching = false
    input.removeClass "editing"
    input.removeClass "searching"
    input.val ""
    arbiter.publish("messages/render")

  $(document).keydown (e) ->
    if (e.which == 13)
      e.preventDefault()
      sendMessage()
    else if (e.which == 40)
      clear(e)
      exportObject.searching = true
      exportObject.editing = false
      input.removeClass "editing"
      input.addClass "searching"
      input.focus()
    else if (e.which == 27)
      clear(e)
    else if (e.which == 38)
      arbiter.publish "messages/getLast", editDoc

  sendButton.click (e) ->
    sendMessage()

  arbiter.subscribe "messages/startEdit", (id) ->
    arbiter.publish "messages/get",
      id: id
      callback: (doc) ->
        if doc.author == localStorage.displayName
          editDoc doc

  exportObject
