define ["arbiter"], (arbiter) ->
  div = document.getElementById('content')
  div.ondragenter = div.ondragover = (e) ->
    e.preventDefault()
    e.dataTransfer.dropEffect = 'copy'
    false
  div.ondrop = (e) ->
    if !e.dataTransfer.files?
      arbiter.publish "messages/send",
        text: "<iframe src=#{e.dataTransfer.getData('Url')}></iframe>"
        author: localStorage.displayName
    for file in e.dataTransfer.files
      formData = new FormData()
      formData.append("file", file, file.name)
      xhr = new XMLHttpRequest()
      xhr.open('post', 'upload', true)
      xhr.onreadystatechange = () ->
        if (this.readyState != 4)
          return
        console.log(this.responseText)
      xhr.send(formData)
    e.preventDefault()
