$(document).ready ->
  $(document).on "change", "#scope-select", ->
  	scope = $(this).val()
  	if scope == 'local'
  		$(".unit_allocate").hide()
  	else
  		$(".unit_allocate").show()	
		return
	
	$(document).on "change", "#promo-user-select", ->
		promo_user = $(this).val()
		if promo_user == 'customer'
			$('#alpha_promotion_count').show()
			$('#scope-select').val('local')
			$('#scope_select_div').hide()
			$(".unit_allocate").hide()
		else if promo_user == 'staff'
			$('#alpha_promotion_count').hide()
			$(".unit_allocate").show()
			$('#scope_select_div').show()
		return