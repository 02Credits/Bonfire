define ["mithril", "moment"], (m, moment) ->
  position: "after"
  name: "time"
  parent: "title"
  render: (doc, renderBefore, renderInner, renderAfter) ->
    (renderBefore doc).then (beforeChildren) ->
      (renderInner doc).then (innerChildren) ->
        (renderAfter doc).then (afterChildren) ->
          if doc.time?
            time = moment.utc(doc.time).local()
            timeText = time.format("M/D/h:mm")
            [
              beforeChildren
              m "p.time-stamp.black-text.right", [
                timeText
                innerChildren
              ]
              afterChildren
            ]
