define ["mithril", "moment"], (m, moment) ->
  position: "after"
  name: "time"
  parent: "title"
  render: (doc, renderBefore, renderInner, renderAfter) ->
    if doc.time?
      time = moment.utc(doc.time).local()
      timeText = time.format("M/D/h:mm")
      [
        renderBefore doc
        m "p.time-stamp.black-text.right", [
          timeText
          renderInner doc
        ]
        renderAfter doc
      ]
