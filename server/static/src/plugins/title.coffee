define ["mithril"], (m) ->
  position: "before"
  name: "title"
  parent: "text"
  render: (doc, renderBefore, renderInner, renderAfter) ->
    if !doc.author?
      doc.author = "error"
    editIcon = if doc.edited then m "i.material-icons.editIcon", "mode_edit" else null
    [
      renderBefore doc
      m "span.card-title", [
        m.trust(doc.author)
        editIcon
        renderInner doc
      ]
      renderAfter doc
    ]
