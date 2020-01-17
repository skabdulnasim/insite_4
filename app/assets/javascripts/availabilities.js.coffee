# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->

	$(document).on "click", ".parent-check", ->
		section_id = $(this).data("section-id")
		if ($('#pc'+section_id).is ":checked")
			$(".cc-"+section_id).prop('checked', true)
		else
			$(".cc-"+section_id).prop('checked', false)
		return