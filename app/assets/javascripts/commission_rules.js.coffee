# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->

	# Function to add products to temporary cart with quantity for adding them to a catalog
	$(document).on "click", ".add-product-to-rule",->
		amount_type = $("#set_output_amount_type").val()
		product_id = $(this).data("product-id")
		item_name = $(this).data("product-name")
		mp_commission_capping = $(this).data("mp-commission-capping")
		if $("#cart_item_#{product_id}").length
			Materialize.toast("#{item_name} already selected.", 3000, 'rounded')
		else
			productData =
				product_id:   product_id
				product_name: item_name
				output_amount_type: amount_type
				mp_commission_capping: mp_commission_capping
			result = JST["templates/commission_rules/add_new_product"](productData)
			$(".no-item-selected").hide()
			$(".selected-product-list").append(result)
			Materialize.toast("#{item_name} selected.", 3000)
		return

	$(document).on "change", "#set_output_amount_type",->
		amount_type = $(this).val()
		$(".output_amount_type").val amount_type
		return

	$(document).on "click", ".remove_cart_item",->
		product_id = $(this).data('product-id')
		$("#cart_item_#{product_id}").remove()
		return

	########### Function to quick update menu products ###########
	$(document).on "click", ".update_rule_input",->
		rule_input_id = $(this).data("rule-input-id")
		rule_output_id = $(this).data("rule-output-id")
		product_name = $(this).data("product-name")
		# output_amount = $(".edit_amount_#{rule_input_id}").val()
		owner_commission = parseFloat($(".edit_owner_commission_amount_#{rule_input_id}").val())
		owner_commission = 0 if isNaN(owner_commission)
		csm_commission = parseFloat($(".edit_csm_commission_amount_#{rule_input_id}").val())
		csm_commission = 0 if isNaN(csm_commission)
		total_commission = owner_commission + csm_commission
		mp_commission_capping = parseFloat($(this).data("mp-commission-capping"))
		if !isNaN(mp_commission_capping) && total_commission > mp_commission_capping
			Materialize.toast("Total commission can't exceed commission capping: #{mp_commission_capping}.", 5000, "red")
			return false
		request = $.ajax(
			type: 'POST'
			url: "/commission_rules/quick_update"
			dataType: "json"
			data:
				rule_output_id: rule_output_id
				owner_commission: owner_commission
				csm_commission: csm_commission
		)
		request.done (data, textStatus, jqXHR) ->
			Materialize.toast("#{name} successfully updated.", 5000)
			$(".rule_output_amount_#{rule_input_id}").html(data.amount)
			$("#rule_input_collapse_#{rule_input_id}").prev('tr').click()
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			Materialize.toast("Some error occured while updating commission rule.", 5000)
			return
		return 

	$(document).on "keyup", ".commission-amounts",->
		product_id = $(this).data('product-id')
		owner_commission = parseFloat($(".owner-commission-amount-#{product_id}").val())
		owner_commission = 0 if isNaN(owner_commission)
		csm_commission = parseFloat($(".csm-commission-amount-#{product_id}").val())
		csm_commission = 0 if isNaN(csm_commission)
		total_commission = owner_commission + csm_commission
		mp_commission_capping = $(this).data('mp-commission-capping')
		if !isNaN(parseFloat(mp_commission_capping)) && parseFloat(mp_commission_capping) > 0
			if total_commission > parseFloat(mp_commission_capping)
				Materialize.toast("Total commission can't exceed commission capping.", 5000, "red")
				$(".owner-commission-amount-#{product_id}").val(0)
				$(".csm-commission-amount-#{product_id}").val(0)
		return