if $('#select_recp').data('users') 
  $('#select_recp').prop("disabled", true)

fill_email_to = (state) ->
  $('#state'+state).click ->
    users = $('#state'+state).data('users')
    $('#event_email_to').val(users)
    if users.length == 0
      $('#event_email_to').attr('placeholder', 'No recipients present for ' + state + ' state')

fill_email_to state for state in ['All', 'Accepted', 'Incomplete', 'Submitted', 'Approved', 'Cancel']
