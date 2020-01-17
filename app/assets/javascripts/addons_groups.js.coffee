# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

	$(document).on "click", ".product_checkbox",->
		product_id = $(this).data("product-id")
		item_qty = if $(".addon_qty_#{product_id}").val().length == 0 then 0 else $(".addon_qty_#{product_id}").val()
		item_unit_id = $(".addon_unit_#{product_id}").val()
		item_price = if $(".addon_price_#{product_id}").val().length == 0 then 0 else $(".addon_price_#{product_id}").val()
		item_name = $(this).data("product-name")
		item_unit = $(".addon_unit_#{product_id} option:selected").html()
		if parseInt(item_qty) == 0
			Materialize.toast("Please provide some valid quantity of #{item_name}.", 3000, "red")
			return false

		if (this.checked)
			if $("#cart_item_#{product_id}").length
				$("#cart_item_#{product_id}").val item_qty
				$("#item_qty_#{product_id}").html item_qty
				$("#cart_item_unit_#{product_id}").val item_unit_id
				$("#item_unit_#{product_id}").html item_unit
				$("#cart_item_price_#{product_id}").val item_price
				$("#item_price_#{product_id}").html "#{item_price} Rs."
			else
				contentStr = "<li class='collection-item' id='li_product_#{product_id}'><div>"
				contentStr += "<input type='checkbox' name='checked_product_ids[]' value='#{product_id}' id='product_#{product_id}' checked>"
				contentStr += "<label for='product_#{product_id}' class='font-sz-11'>#{item_name}</label>"
				contentStr += "<span class='secondary-content font-sz-11'><span id='item_qty_#{product_id}'>#{item_qty}</span> <span id='item_unit_#{product_id}'>#{item_unit}</span> <span id='item_price_#{product_id}'>#{item_price} Rs.</span> </span>"
				contentStr += "<input type='hidden' name='ammount#{product_id}' value='#{item_qty}' id='cart_item_#{product_id}'/>"
				contentStr += "<input type='hidden' name='price#{product_id}' value='#{item_price}' id='cart_item_price_#{product_id}'/>"
				contentStr += "<input type='hidden' name='product_unit_id#{product_id}' value='#{item_unit_id}' id='cart_item_unit_#{product_id}'/>"
				contentStr += "</div></li>"
				$(".no-item-selected").hide()
				$(".ag-product-list").prepend(contentStr)
		else
			$(".ag-product-list").find("#li_product_#{product_id}").remove()
		return

	$(document).on "keyup change", ".addon-input",->
		product_id = $(this).data("product-id")
		item_qty = if $(".addon_qty_#{product_id}").val().length == 0 then 0 else $(".addon_qty_#{product_id}").val()
		item_unit_id = $(".addon_unit_#{product_id}").val()
		item_price = if $(".addon_price_#{product_id}").val().length == 0 then 0 else $(".addon_price_#{product_id}").val()
		# item_name = $(this).data("product-name")
		item_unit = $(".addon_unit_#{product_id} option:selected").html()
		if parseInt(item_qty) == 0
			Materialize.toast("Please provide some valid quantity.", 3000, "red")
			return false
		if $("#li_product_#{product_id}").length
			$("#cart_item_#{product_id}").val item_qty
			$("#item_qty_#{product_id}").html item_qty
			$("#cart_item_unit_#{product_id}").val item_unit_id
			$("#item_unit_#{product_id}").html item_unit
			$("#cart_item_price_#{product_id}").val item_price
			$("#item_price_#{product_id}").html "#{item_price} Rs."
		return