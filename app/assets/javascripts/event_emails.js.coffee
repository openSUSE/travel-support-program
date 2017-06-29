if $('#select_recp').data('users') 
	$('#select_recp').prop("disabled", true)
	$('.col-md-10').prepend("<div class='alert alert-warning'>There are no participants present</div>")

states = (state) ->
	$('#state'+state).click ->
		$('.alert').remove()
		users = $('#state'+state).data('users')
		$('#event_email_to').val(users)
		if users.length == 0
		  $('.col-md-10').prepend("<div class='alert alert-warning'>There are no participants present</div>")

states state for state in ['All', 'Accepted', 'Incomplete', 'Submitted', 'Approved', 'Cancel']
