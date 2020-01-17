# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
	$(document).on 'change keyup', '#cash_out_amount', (evt) ->
		amount = parseFloat($(this).val())
		current = parseFloat($("#current_amount").val())
		if ((amount > current) || (amount <= 0 or isNaN(amount)) )
			$(this).addClass('error-rais')
			if (amount > current)
				Materialize.toast("The amount is more than current cash amount", 3000, 'red')
			else if (amount <= 0 or isNaN(amount))
				Materialize.toast("Please enter valid amount", 3000, 'red')
				$(".payment-save").attr('disabled', true)
			return
		else
			$(this).removeClass('error-rais')
			$(".payment-save").attr('disabled', false)
		return

	$(document).on "keyup",".cash-out-denomination", ->
	  amount = 0
	  $(".cash-out-denomination").each ->
	  	count = $(this).val()
	  	count_value = $(this).attr('data-denomination-value')
	  	calculate_amount = count * count_value
	  	amount = amount + calculate_amount
	  	$('input[name="cash_out[amount]"]').val(amount)
	  	$('#cash_out_amount').attr('readonly',true)
    return

  




  	