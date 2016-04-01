define ["./commands/giphy"], () ->
  commandProcessors = arguments
  (text) ->
    commandRegex = /^\/[^\s]+/
    possibleMatch = text.match commandRegex
    if possibleMatch?
      command = possibleMatch[0]
      commandArg = text.substring possibleMatch[0].length
      for commandProcessor in commandProcessors
        commandProcessor(command, commandArg)
