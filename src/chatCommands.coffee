define [
  "./commands/giphy",
  "./commands/emoticonDirectory",
  "./commands/refresh",
  "./commands/megaKeith"
], ->
  commandProcessors = arguments
  (command, args) ->
    for commandProcessor in commandProcessors
      commandProcessor(command, args)
