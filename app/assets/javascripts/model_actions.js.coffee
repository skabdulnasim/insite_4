# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
	$(document).on 'click', 'form .remove_reason_code', (event)->
		reason_code_id = $(this).data("reason-code-id")
		remove_btn = $(this)
		if reason_code_id != undefined
			request = $.ajax(
				type: 'POST'
				url: "/cancelation_policies/delete_cancelation_cause"
				dataType: "json"
				data:
					reason_code_id: reason_code_id
			)
			request.done (data, textStatus, jqXHR) ->
				remove_btn.closest('.form-group').next('input[type=hidden]').remove()
				remove_btn.closest('.form-group').remove()
				return
			request.error (jqXHR, textStatus, errorThrown) ->
				alert "Something went wrong"
				return
		else
			$(this).closest('.remove-card').remove()
		event.preventDefault()

	$(document).on 'click', 'form .add_fields', (event)->
		time = new Date().getTime()
		regexp = new RegExp($(this).data('id'), 'g')
		$(this).before($(this).data('fields').replace(regexp,time))
		event.preventDefault()