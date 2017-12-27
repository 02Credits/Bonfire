define ["mithril", "arbiter", "linkify"], (m, arbiter, linkify) ->
  name: "container"
  parent: "root"
  render: (doc, renderBefore, renderInner, renderAfter) ->
    if doc.text?
      if Array.isArray(doc.text)
        doc.links = []
        for text in doc.text
          if text.text.indexOf("<") != 0
            for link in linkify.find(text.text)
              doc.links.push(link)
      else if doc.text.indexOf("<") != 0
        doc.links = linkify.find doc.text

    # yes this is gross. It will be made better with async in typescript. This is temp
    (renderBefore doc).then (beforeChildren) ->
      (renderInner doc).then (innerChildren) ->
        (renderAfter doc).then (afterChildren) ->
          m ".message-container." + doc.author, { key: doc["_id"] },
            m ".message.blue-grey.lighten-5",
            {
              ondblclick: ->
                if not Array.isArray(doc.text)
                  arbiter.publish "messages/startEdit", doc._id
              style: {
                position: "relative"
              }
            }, [
              beforeChildren
              m ".message-content.black-text",
                innerChildren
              afterChildren
            ]
