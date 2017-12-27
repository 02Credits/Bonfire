define ["arbiter", "pouchdbManager"], (arbiter, PouchDB) ->
  db = new PouchDB('http://73.193.51.132:5984/attachments')
  # 15 * 10 megs or 150 megs
  maxSize = 15 * 1000 * 1000 * 10
  currentSize = 0
  idQueue = []
  # object of string to
  #   name: string
  #   fileId: string
  #   attachment:
  #     data: blob
  #     content_type: number
  fileMap = {}
  arbiter.subscribe "files/fetch", (fileId) ->
    if fileId of fileMap
      arbiter.publish "file/data", fileMap[fileId]
    else
      db.get(fileId, {attachments: true, binary: true})
        .then (doc) ->
          for name, attachment of doc["_attachments"]
            currentSize += attachment.data.size
            while currentSize > currentSize
              poppedId = idQueue.shift()
              poppedData = fileMap[poppedId]
              delete fileMap[poppedId]
              currentSize = currentSize - poppedData.attachment.data.size
            idQueue.push(fileId)
            fileMap[fileId] = {id: fileId, name: name, attachment: attachment}
            arbiter.publish "file/data", fileMap[fileId]
