# Using jquery-ui autocomplete for users
$('#event_organizer_user_email').autocomplete(
  source: $('#event_organizer_user_email').data('users'),
  minLength: 2,
  response: ( event, ui ) ->
            ui.content[0] = {0: "No existing matches", 1: ""} if ui.content.length == 0
  select: ( event, ui ) ->
          $( '#event_organizer_user_email' ).val( ui.item[1] )
          return false
).autocomplete('instance')._renderItem = (ul, item) ->
  $('<li>').append('<div> <strong>Nickname</strong>: ' + item[0] + '<br>' + '<strong>Email</strong>: ' + item[1] + '</div>').appendTo ul
