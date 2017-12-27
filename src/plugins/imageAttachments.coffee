define ["mithril", "arbiter", "pouchdbManager"], (m, arbiter, PouchDB) ->
  db = new PouchDB('http://73.193.51.132:5984/attachments')
  name: "imageAttachments"
  parent: "images"
  render: (doc, renderChildren) ->
    (renderChildren doc).then (children) ->
      if doc.file? or doc.files?
        if (doc.file)
          doc.files = [doc.file]
        renderedFiles = []
        thenables = for file in doc.files
          new Promise (resolve, reject) ->
            arbiter.publish "files/fetch", file
            id = arbiter.subscribe "file/data", (fileData) ->
              if fileData.id == file
                if fileData.attachment.content_type.startsWith("image")
                  renderedFiles.push (m "img.materialboxed", {src: URL.createObjectURL(fileData.attachment.data)})
                arbiter.unsubscribe id
                resolve()
        Promise.all(thenables).then () ->
          [
            renderedFiles
            children
          ]
      else
        [children]
