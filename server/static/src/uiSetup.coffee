define ["jquery", "materialize"], ($) ->
  $(document).ready ->
    $('.modal-trigger').leanModal();

  $('#settings').click (e) ->
    $('label').addClass "active"
