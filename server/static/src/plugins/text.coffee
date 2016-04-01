define ["mithril", "linkify-string", "emoticons"], (m, linkify, emoticons) ->
  name: "text"
  parent: "container"
  render: (doc, renderBefore, renderAfter) ->
    if !doc.text?
      doc.text = "error"
    greenText = if doc.text.indexOf(">") == 0 then ".greentext" else ""
    text = doc.text
    if doc.text.indexOf("<") != 0
      text = linkify("#{doc.text}")
      text = emoticons(text)
    [
      renderBefore doc
      m "p#{greenText}", m.trust(text)
      renderAfter doc
    ]
