define ["jquery", "arbiter", "pouchdbManager", "moment"], ($, arbiter, PouchDB, moment) ->
  db = new PouchDB('http://73.193.51.132:5984/attachments')
  div = document.getElementById('content')
  div.ondragenter = div.ondragover = (e) ->
    e.preventDefault()
    e.dataTransfer.dropEffect = 'copy'
    false
  uploadFiles = (files) ->
    for file in files
      blob = file.slice()
      if blob.size > 15000000
        arbiter.publish 'messages/send', {author: localStorage.displayName, text: "FILE TOO BIG"}
      else
        db.allDocs
          include_docs: true
          conflicts: false
          limit: 1
          descending: true
          startkey: "_design"
        .then (results) ->
          messageNumber = 0
          if results.rows.length > 0
            messageNumber = parseInt(results.rows[0].doc.messageNumber) + 1
          time = moment().utc().valueOf()
          id = messageNumber.toString() + time.toString()
          attachments = {}
          attachments[file.name] =
            data: blob
            content_type: file.type
          db.put
            _id: id
            messageNumber: messageNumber.toString(),
            _attachments: attachments
          .then () ->
            arbiter.publish 'messages/send', {author: localStorage.displayName, file: id}
          .catch (err) ->
            arbiter.publish "error", err
  div.ondrop = (e) ->
    try
      url = e.dataTransfer.getData('URL')
      sent = false
      if url != ""
        sent = true
        $('.progress').fadeIn()
        $.ajax
          url: 'https://api.imgur.com/3/image'
          headers:
            'Authorization': 'Client-ID c110ed33b325faf'
          type: 'POST'
          data:
            'image': url
            'Authorization': 'Client-ID c110ed33b325faf'
          success: (result) ->
            arbiter.publish 'messages/send', {text: result.data.link, author: localStorage.displayName}
            $('.progress').fadeOut()
          error: () ->
            Materialize.toast("Image URL Upload Failed", 4000)
            $('.progress').fadeOut()
      else
        if e.dataTransfer.files.length != 0
          uploadFiles(e.dataTransfer.files)
    catch error
      arbiter.publish 'error', error
    e.preventDefault()
