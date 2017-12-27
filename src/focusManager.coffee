define [], () ->
  exportObject = {}
  onBlur = () ->
    exportObject.focused = false
  onFocus = () ->
    exportObject.focused = true
    if window.notifier?
      window.notifier.notify(false)
  window.onblur = onBlur
  window.onfocus = onFocus
  exportObject
