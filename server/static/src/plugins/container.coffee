define ["mithril", "arbiter", "linkify"], (m, arbiter, linkify) ->
  name: "container"
  parent: "root"
  render: (doc, renderBefore, renderInner, renderAfter) ->
    if doc.text? and doc.text.indexOf("<") != 0
      doc.links = linkify.find doc.text
    m ".message-container", { key: doc["_id"] },
      m ".message.blue-grey.lighten-5",
      {
        ondblclick: ->
          arbiter.publish "messages/startEdit", doc._id
      }, [
        renderBefore doc
        m ".message-content.black-text",
          renderInner doc
        renderAfter doc
      ]
