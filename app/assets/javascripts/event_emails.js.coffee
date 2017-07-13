if $('#select_recp').data('users') 
  $('#select_recp').prop("disabled", true)

# To remove the duplicate values from an array
array_unique = (array) ->
  unique_value = []
  unique_value.push i for i in array when not (i in unique_value)
  return unique_value

# To evaluate the user emails
users = (value = []) ->
  $("input[type='checkbox']:checked").each ->
    if $(this).data('users') != ''
      value = value.concat $(this).data('users')
      $(this).parent().addClass('selected')
  return array_unique(value)

# Provide every checkbox with a click event
$("input[type='checkbox']").each ->
  $(this).click ->
    $(this).parent().removeClass('selected')
    value = users()
    if value.length == 0 && $("input[type='checkbox']:checked").length > 0
      $('#event_email_to').val('No recipients')
    else
      $('#event_email_to').val(value)

$('#state-menu').click (event) ->
  event.stopPropagation()
