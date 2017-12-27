// Generated by CoffeeScript 1.12.0
(function() {
  define(["mithril", "moment"], function(m, moment) {
    return {
      position: "after",
      name: "time",
      parent: "title",
      render: function(doc, renderBefore, renderInner, renderAfter) {
        return (renderBefore(doc)).then(function(beforeChildren) {
          return (renderInner(doc)).then(function(innerChildren) {
            return (renderAfter(doc)).then(function(afterChildren) {
              var time, timeText;
              if (doc.time != null) {
                time = moment.utc(doc.time).local();
                timeText = time.format("M/D/h:mm");
                return [beforeChildren, m("p.time-stamp.black-text.right", [timeText, innerChildren]), afterChildren];
              }
            });
          });
        });
      }
    };
  });

}).call(this);
