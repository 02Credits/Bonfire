define ["plugins", "arbiter", "underscore"], (pluginsList, arbiter, _) ->
  plugins = []
  for pluginList in pluginsList
    plugins = plugins.concat pluginList

  root = {}
  pluginDirectory = {}

  # List pass
  for plugin in plugins
    if plugin.parent == "root"
      root = plugin
    pluginDirectory[plugin.name] = plugin
    plugin.beforePlugins = []
    plugin.innerPlugins = []
    plugin.afterPlugins = []

  # Tree pass
  for plugin in plugins
    if not pluginDirectory[plugin.parent]? and plugin.parent != "root"
      arbiter.publish "error", "nonexistant plugin parent #{plugin.parent}"
    else if plugin != root
      parent = pluginDirectory[plugin.parent]
      if plugin.position?
        if plugin.position == "before"
          parent.beforePlugins.push plugin
        else if plugin.position == "after"
          parent.afterPlugins.push plugin
        else if plugin.position == "inner"
          parent.innerPlugins.push plugin
      else
        parent.innerPlugins.push plugin

  generateRenderChildren = (children) ->
    (context) ->
      Promise.all (renderPlugin context, plugin for plugin in children)

  renderPlugin = (context, plugin) ->
    renderBefore = generateRenderChildren plugin.beforePlugins
    renderInner = generateRenderChildren plugin.innerPlugins
    renderAfter = generateRenderChildren plugin.afterPlugins
    vEl = []
    if plugin.render.length == 4
      vEl = plugin.render(context, renderBefore, renderInner, renderAfter)
    else if plugin.render.length == 3
      renderInnerAndAfter = (context) ->
        children = []
        .concat renderInner(context)
        .concat renderAfter(context)
        Promise.all(children)
      vEl = plugin.render(context, renderBefore, renderInnerAndAfter)
    else
      renderAll = (context) ->
        children = []
        .concat renderBefore(context)
        .concat renderInner(context)
        .concat renderAfter(context)
        Promise.all(children)
      vEl = plugin.render(context, renderAll)
    vEl

  rootPlugin: root
  pluginDirectory: pluginDirectory
  render: (message) ->
    renderPlugin message, root
