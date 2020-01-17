# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
	$(document).on 'click', 'form .remove_cancelation_causes', (event)->
		cancelation_cause_id = $(this).data("cancelation-cause-id")
		remove_btn = $(this)
		if cancelation_cause_id != undefined
			request = $.ajax(
				type: 'POST'
				url: "/cancelation_policies/delete_cancelation_cause"
				dataType: "json"
				data:
					cancelation_cause_id: cancelation_cause_id
			)
			request.done (data, textStatus, jqXHR) ->
				remove_btn.closest('.form-group').next('input[type=hidden]').remove()
				remove_btn.closest('.form-group').remove()
				return
			request.error (jqXHR, textStatus, errorThrown) ->
				alert "Something went wrong"
				return
		else
			$(this).closest('.form-group').remove()
		event.preventDefault()

	$(document).on 'click', 'form .add_fields', (event)->
		time = new Date().getTime()
		regexp = new RegExp($(this).data('id'), 'g')
		$(this).before($(this).data('fields').replace(regexp,time))
		event.preventDefault()