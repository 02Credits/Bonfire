define ["jquery", "underscore", "inputManager", "arbiter"], ($, _, inputManager, arbiter) ->
  exportObject = {}
  exportObject.stuck = true
  exportObject.messages = 50

  atBottom = () ->
    scrollElement = exportObject.scrollElement
    if scrollElement?
      scrollElement[0].scrollHeight - scrollElement.scrollTop() == scrollElement.outerHeight()
    else
      true

  atTop = () ->
    scrollElement = exportObject.scrollElement
    if scrollElement?
      scrollElement.scrollTop() == 0
    else
      true

  addMessages = () ->
    if !inputManager.searching
      scrollHeight = exportObject.scrollElement[0].scrollHeight
      exportObject.messages += 50
      arbiter.publish('messages/render')
      token = {}
      token = arbiter.subscribe 'messages/rendered', () ->
        arbiter.unsubscribe token
        exportObject.scrollElement.scrollTop(exportObject.scrollElement[0].scrollHeight - scrollHeight)
  addMessages = _.throttle(addMessages, 1000, {trailing: false})

  onMouseWheel = (e) ->
    if e.wheelDelta > 0
      exportObject.stuck = false
    else if exportObject.scrollElement?
      scrollElement = exportObject.scrollElement
      exportObject.stuck = scrollElement[0].scrollHeight - scrollElement.scrollTop() == scrollElement.outerHeight()

  exportObject.scrollToBottom = ->
    exportObject.scrollElement.scrollTop exportObject.scrollElement[0].scrollHeight
  exportObject.scrollIfStuck = ->
    if exportObject.stuck
      exportObject.messages = 50
      exportObject.scrollToBottom()
    else if atTop()
      addMessages()

  exportObject.scrollElement = $('#messages')
  setInterval exportObject.scrollIfStuck, 100
  exportObject.scrollElement.scroll exportObject.scrollIfStuck

  exportObject.lastTouchY = 0
  touchShim = (e) ->
    touchY = e.targetTouches[0].pageY
    onMouseWheel { wheelDelta: exportObject.lastTouchY - touchY }
    exportObject.lastTouchY = touchY
  document.addEventListener "mousewheel", onMouseWheel, true
  document.addEventListener "touchmove", touchShim, true
  exportObject
