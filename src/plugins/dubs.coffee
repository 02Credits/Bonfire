define ["mithril", "moment", "jquery"], (m, moment, $) ->
  position: "inner"
  name: "dubs"
  parent: "time"
  render: (doc, renderBefore, renderAfter) ->
    (renderBefore doc).then (beforeChildren) ->
      (renderAfter doc).then (afterChildren) ->
        if doc.time?
          dubsString = moment(doc.time).valueOf().toString()
          length = dubsString.length
          dubsString = dubsString.substring(length - 9, length)
          dubsColors =
          1: "#9d9d9d"
          2: "#1eff00"
          3: "#0070dd"
          4: "#a335ee"
          5: "#ff8000"
          6: "#e6cc80"
          7: "#e6cc80"

          newDubsString = ""
          dubsChar = dubsString.charAt(dubsString.length-1)
          dubsList = dubsChar
          for i in [(dubsString.length-2)..0]
            char = dubsString.charAt(i)
            if char != dubsChar
              newDubsString = char + newDubsString
              dubsChar = ""
            else
              dubsList = char + dubsList

          flashFunction = (element, isInitialized) -> {}

          if dubsList.length != 1
            flashFunction = (element, isInitialized) ->
              if not isInitialized
                dubsColor = dubsColors[dubsList.length]
                previousColor = "#424242"
                $('body').css("transition", "0s")
                $('body').css("background-color", dubsColor)
                setTimeout(() ->
                  $('body').css("transition", "background-color 1s")
                  $('body').css("background-color", previousColor)
                ,250)

          dubsElement = m "span", {config: flashFunction, style: "color:#{dubsColors[dubsList.length]} !important"},
            dubsList

          # this is fine because Im returning a list and it will be handled on the plugin side
          [
            beforeChildren
            m.trust "<br>"
            newDubsString
            dubsElement
            afterChildren
          ]
