# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
	$(document).on "keyup",".cash-in-denomination", ->
		amount = 0
		$(".cash-in-denomination").each ->
			count = $(this).val()
			count_value = $(this).attr("data-denomination-value")
			calculate_amount = count * count_value
			amount = amount + calculate_amount
			$('input[name="cash_in[amount]"]').val(amount)
			$("#cash_in_amount").attr('readonly',true)
		return

	$(document).on "change keyup", "#cash_in_amount", ->
		amount = parseFloat($(this).val())
		if amount <= 0 or isNaN(amount)
			$(this).addClass('error-rais')
			Materialize.toast("Please enter valid amount", 3000, 'red')
			$(".payment-save").attr('disabled', true)
		else
			$(this).removeClass('error-rais')
			$(".payment-save").attr('disabled', false)
		return

