define ["mithril"], (m) ->
  imageRegex = /\.(?:jpg|gif|png|jpeg|bmp|JPG|GIF|PNG|JPEG|BMP)(?:\?[^=&]+=[^=&]+(?:&[^=&]+=[^=&]+)*)?$/
  imageConfig = (element, isInitialized) ->
    if not isInitialized
      $(element).materialbox()
  imgurRegex = /https?:\/\/(i\.)?imgur\.com\/(gallery\/)?(.*?)(?:[#\/].*|$)/
  gfycatRegex = /(?:^https?:\/\/gfycat.com\/)/
  gfycatConfig = (element, isInitialized) ->
    if not isInitialized
      new gfyObject(element).init()
  gifvRegex = /.(?:gifv|GIFV)$/
  videoRegex = /.webm|.wmv|.mp4$/
  youtubeRegex = /(?:(?:https?:\/\/www\.youtube\.com\/watch\?v=)|(?:^https?:\/\/youtu.be\/))([^#\&\?]*)(?:\?t=(\d+h)?(\d+m)?(\d+s)?)?/

  preventDrag = (event) => event.preventDefault()

  name: "images"
  parent: "container"
  position: "before"
  render: (doc, renderChildren) ->
    (renderChildren doc).then (children) ->
      m ".card-image", {width: "80%"}, [
        if doc.links?
          images = []
          for link in doc.links
            if imageRegex.test link.href
              images.push (m "img.materialboxed", { config:imageConfig, src:"#{link.href}", ondragstart: preventDrag })
            else if gifvRegex.test link.href
              link.href = link.href.substring(0, link.href.length - 4) + "mp4"
            else if imgurRegex.test link.href
              match = link.href.match imgurRegex
              images.push (m "img.materialboxed", { config:imageConfig, src:"http://i.imgur.com/#{match[3]}.jpg", ondragstart: preventDrag })
            if gfycatRegex.test link.href
              id = link.href.replace gfycatRegex, ''
              images.push (m "img.gfyitem#giphyId=#{id}", { config:gfycatConfig, "data-id":id, "data-controls":true, ondragstart: preventDrag })
            if videoRegex.test link.href
              images.push (m "video.responsive-video", {
                controls:true,
                loop: true,
                autoplay: true,
                muted: true,
                width: "100%",
                src: link.href
              })
            if youtubeRegex.test link.href
              match = link.href.match youtubeRegex
              youtubeId = match[1]
              start = ""
              seconds = 0
              if match[2]?
                seconds += parseInt(match[2]) * 60 * 60
              if match[3]?
                seconds += parseInt(match[3]) * 60
              if match[4]?
                seconds += parseInt(match[4])
              if seconds != 0
                start = "&start=" + seconds
              youtubeElement = m ".video-container[no-controls]",
                m "iframe", {
                  width: "853"
                  height: "480"
                  src: "http://www.youtube.com/embed/#{youtubeId}?rel=0;autohide=1#{start}"
                  frameborder: "0"
                  allowfullscreen: true
                }
              images.push youtubeElement
          images
        children
      ]
