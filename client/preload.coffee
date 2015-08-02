notifier = {}

remote = require 'remote'

notifier.notify = (value) ->
  thisWindow = remote.getCurrentWindow()
  thisWindow.flashFrame(value)


window.notifier = notifier
