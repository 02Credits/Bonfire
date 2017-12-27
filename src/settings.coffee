define ["jquery"], ($) ->
  nameInput = $('#displayName')
  statusInput = $('#status')

  if localStorage.displayName?
    nameInput.val localStorage.displayName
  else
    dumbNames = [
            # "Village Idiot",
            # "Dirty Peasant",
            # "Dumbster",
            # "assfaggot"
        "anon"
      ]
    randomIndex = Math.floor(Math.random() * dumbNames.length)
    nameInput.val dumbNames[randomIndex]
    localStorage.displayName = dumbNames[randomIndex]

  if localStorage.status?
    statusInput.val localStorage.status
  else
    localStorage.status = "Breathing"
    statusInput.val localStorage.status

  settingsInputs = $(".settings-input")
  settingsInputs.keydown (e) ->
    if e.which == 13 or e.which == 27
      this.blur()

  settingsInputs.blur (e) ->
    localStorage[$(this).attr('id')] = $(this).val()
