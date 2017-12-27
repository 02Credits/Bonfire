define ["pouchdbManager", "arbiter"],
(PouchDB, arbiter) ->
  messages = new PouchDB('http://73.193.51.132:5984/messages')

  authorMappings =
    Jonjo: ["JonJo"]
    Derek: ["Derek", "Daeryk", "Derk"]
    Honry: ["Honry", "Henry", "Eri", "Honri"]
    Keith: ["Keith", "Keith Surface", "Keith Test", "Keith Mobile"]

  stepObject = (obj) ->
    keys = Object.keys(obj)
    count = 0
    result = []
    keys.forEach (key) ->
      count = count + obj[key]
      for i in [1..obj[key]]
        result.push key
    count: count
    result: result

  pickWeighted = (steppedObj) ->
    index = Math.floor(Math.random() * steppedObj.count)
    steppedObj.result[index]

  setupData = (lines) ->
    data = {}
    starters = {}
    lines.forEach (line) ->
      line.trim()
      if line && ("" != line)
        text = line.toLowerCase()
        if not text.startsWith("<")
          words = text.split(" ")
          if words.length > 3
            for i in [0..(words.length-2)]
              first = words[i]
              second = words[i+1]
              res = words[i+2]
              key = first + " " + second;

              if i == (words.length - 3)
                res = res + "\n"

              if i == 0
                if key in starters
                  starters[key]++
                else
                  starters[key] = 1

              if key in data
                entry = data[key]
                if res in entry
                  entry[res]++
                else
                  entry[res] = 1
              else
                data[key] = {}
                data[key][res] = 1;
    starters = stepObject starters
    dataKeys = Object.keys(data)
    dataKeys.forEach (key) ->
      data[key] = stepObject(data[key])

    data: data
    starters: starters

  attempts = 0
  tryGenerate = (author, id) ->
      actualNames = authorMappings[author]
      Promise.all(messages.query("by_author", {key: alternateName}) for alternateName in actualNames)
      .then (results) ->
        lines = []
        for result in results
          for row in result.rows
            lines.push row.value
        response = setupData lines

        starter = pickWeighted response.starters
        starterWords = starter.split " "
        secondToLast = starterWords[0]
        last = starterWords[1]
        line = starter
        while true
          next = pickWeighted response.data[secondToLast + " " + last]
          line += " " + next
          break if next.endsWith "\n"
          secondToLast = last
          last = next

        arbiter.publish "messages/edit",
          id: id
          text: "Mini#{author} says: " + line.charAt(0).toUpperCase() + line.slice(1)
          skipMarkEdit: true
      .catch (reason) ->
        if attempts > 4
          console.log(reason)
          arbiter.publish "messages/edit",
            id: id
            text: "Mini#{author} had an error..."
            skipMarkEdit: true
        else
          attempts = attempts + 1
          tryGenerate(author, id)

  (author, id) ->
    if author of authorMappings
      attempts = 0
      tryGenerate author, id

