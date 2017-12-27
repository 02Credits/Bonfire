define ["jquery", "materialize", "cards"], ($, materialize, cards) ->
  $(document).ready ->
    $('.modal-trigger').leanModal();

  $('#settings').click (e) ->
    $('label').addClass "active"

  cards()
