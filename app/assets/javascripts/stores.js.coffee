# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
	checked_raw = []
	$(document).on "change", ".destination-store-list", (event) ->
		if $(this).val() != ''
			$(".transfer-boxing-btn").prop("disabled",false)
		else
			$(".transfer-boxing-btn").prop("disabled",true)

	$(document).on "click", ".remove_fields", (event) ->
		$(this).prev('input[type=hidden]').val('1')
		$(this).closest('tr').hide()
		event.preventDefault()

	# Hide secondary store selector on page load
	$('.stock_transfer_destination_store_container').hide()
	$('.stock_transfer_vehicle_container').hide()

	# Token input for products
	$('#stock_transfer_product_tokens').tokenInput '/products.json', theme: 'facebook', prePopulate: $('#stock_transfer_product_tokens').data('load')
	$('#stock_transfer_production_product_tokens').tokenInput '/products.json', theme: 'facebook', prePopulate: $('#stock_transfer_production_product_tokens').data('load')

	# Generating dynamic store dropdown based on stock transfer type
	$(document).on 'change', '#stock_transfer_transfer_type', (evt) ->
		transfer_type = $("#stock_transfer_transfer_type option:selected").val()
		if transfer_type is 'to_other_store'
			$('.stock_transfer_vehicle_container').show()
		else
			$('.stock_transfer_vehicle_container').hide()
		$.ajax '/stores',
			type: 'GET'
			dataType: 'script'
			data: {
				transfer_type: transfer_type
				store_id: $(this).data('store-id')
			}
			error: (jqXHR, textStatus, errorThrown) ->
				alert "AJAX Error: #{textStatus}"
			success: (data, textStatus, jqXHR) ->
				$('.stock_transfer_destination_store_container').show()
				console.log("Dynamic store select OK!")

	$(document).on 'keyup change', '.item-autosubmit-input',->
		# Materialize.toast("Saving...", 3000, 'rounded')
		$('.transfer_item_autosubmit_form').submit()
		return

	$(document).on 'keyup change', '.autosubmit-input',->
		# Materialize.toast("Saving...", 3000, 'rounded')
		$('.transfer_autosubmit_form').submit()
		return

	$('.finish_button').click (event) ->
		product_input = $(".autosubmit-input-quantity").length
		if product_input != 0
			$(".autosubmit-input-quantity").each () ->
				current_stock = $(this).data("current-stock")
				value = $(this).val()
				if (($(this).val() == '') || ($(this).val() == '0'))
					$(this).addClass('error-rais')
					Materialize.toast("Provide some quantity for #{$(this).data("name")}", 5000, 'rounded')
					event.preventDefault() 
				if value > current_stock   
					$(this).addClass('error-rais')
					Materialize.toast("#{value} #{$(this).data("product-basic-unit")} of #{$(this).data("name")} are not available.", 5000,'red')
					event.preventDefault() 
		else
			Materialize.toast("Add some product to transfer.", 5000, 'rounded')   
			event.preventDefault()
		
	$(document).on 'click', '.confirm-transfer', ->
		flag = 0
		$(".destroy_item").each () ->
			if $(this).val() == 'false'
				flag = 1
		if flag == 0
			Materialize.toast("There are no item to transfer", 5000, 'rounded')
			return false
		if $(".quantity_price").val() == ''
			Materialize.toast("Price can't be blank.", 5000, 'rounded')  
			return false
		return    

	$(document).on 'keyup change', '.autosubmit-input-quantity',->  
		val = $(this).val()
		current_stock = $(this).data("current-stock")
		if val > current_stock
			$(this).addClass('error-rais')
			$(this).val ''
			Materialize.toast("#{val} #{$(this).data("product-basic-unit")} of #{$(this).data("name")} are not available.", 5000,'red')
			return false
		if val == '0' 
			$(this).addClass('error-rais')
			$(this).val ''
			Materialize.toast("Transfer quantity must be greater than 0", 5000,'red')
			return false

	$(document).on 'change', '.autosubmit-input-quantity',->
		# Materialize.toast("Saving...", 3000, 'rounded')
		$('.transfer_autosubmit_form').submit()

	$(document).on "change", ".auto_populate_entity",->
		total_count = $(this).data('total-count')
		counter = $(this).data('counter')
		entity_type = $(this).data('entity-type')
		entity_value = $(this).val()
		while counter <= total_count-1
			$(".#{entity_type}_serial_#{counter} option[value=#{entity_value}]").prop('selected',true);
			counter++
		return

	$(document).on "click", ".select-unit-products",->
		$('.available-products:checkbox:checked').map ->
			product_id = @value
			item_name = $(this).data("product-name")
			item_unit = $(this).data("product-unit")
			if $("#cart_item_#{product_id}").length
				Materialize.toast("#{item_name} already selected.", 3000, 'rounded')
			else
				# Materialize.toast("#{item_name} selected.", 3000, 'rounded')
				contentString = "<tr class='data-table__selectable-row' id='cart_item_#{product_id}'>"
				contentString += "<td>##{product_id}<input type='hidden' name='products[]' value='#{product_id}'></td>"
				contentString += "<td>#{item_name}</td>"
				contentString += "</tr>"
				$(".no-item-selected").hide()
				$(".unit-product-list").prepend(contentString)

			return
		return
	############## FUnction to allow numeric valiues only ##############
	isNumber = (evt) ->
		charCode = (if (evt.which) then evt.which else event.keyCode)
		return false  if charCode isnt 45 and (charCode isnt 46 or $(this).val().indexOf(".") isnt -1) and (charCode < 48 or charCode > 57)
		true
	$(".numeric-only").keypress (event) ->
		isNumber event

	############## Assigning modal type value in hidden field #######################
	$(".modal-btn-custom").on "click", ->
		id = $(this).attr('data-transfer-type')
		$('.recipient-type').val id
		return
	###################### for trans_to_kitchen ##############################
	$(document).on 'click', '.kitchen-pro-menu-child-check', ->
		mp_id = $(this).val()
		if ($(this).is ":checked")
			sub_product = $(".menu-subnumbers#{mp_id}")
			for sub_p in (sub_product)
				console.log(sub_p)
				input = document.createElement("INPUT")
				input.setAttribute("type", "hidden")
				input.setAttribute('value',sub_p.value)
				input.name = "menu_product_#{mp_id}_raw_#{sub_p.dataset.productId}"
				input.className = "dynamic_elem_#{mp_id}"
				input.id = "#{mp_id}_#{sub_p.dataset.productId}"
				$("#dynamic_form").append(input)
			mp_quantity = $("input[type='text'][name='quantity_#{mp_id}']").val()
			$("#hidden_quantity_#{mp_id}").val(mp_quantity)
			if (jQuery.inArray(mp_id,checked_raw)==-1)
				checked_raw.push(mp_id)
		else
			$(".dynamic_elem_#{mp_id}").remove()
			checked_raw.splice(checked_raw.indexOf(mp_id), 1)
		$("#checked_raw_").val(checked_raw)

		estimate_raw_qty mp_id
		return

	#### update raw product quantity on hidden field ################## 
	$(document).on "keyup", ".menu_sub_number", ->
		estimate_raw_qty($(this).data("menu-pro-id"))
		$("#"+$(this).data("menu-pro-id")+"_"+$(this).data("product-id")).val($(this).val())
		return
	$(document).on "keyup change", ".menu-numbers", ->
		qnt = $(this).val()
		menu_pro_id = $(this).attr('id')
		qnty = parseFloat(qnt)

		if ($(".menu-pro-check-#{menu_pro_id}").is ":checked")
			$("#hidden_quantity_#{menu_pro_id}").val(qnty)
			if (jQuery.inArray(menu_pro_id,checked_raw)==-1)
				checked_raw.push(menu_pro_id)

		$(".menu-subnumbers"+menu_pro_id).each (index) ->
			val = parseFloat($(this).attr('id'))
			ultimate = val*qnty
			$(this).val(ultimate)
			#console.log("#"+menu_pro_id+"_"+$(this).data('product-id'))
			$("#"+menu_pro_id+"_"+$(this).data('product-id')).val(ultimate)
			return
		estimate_raw_qty menu_pro_id #Update consumption overview
		return
	############### Kitchen production function (Estimate overall consumption) ###############
	estimate_raw_qty = (menu_pro_id) ->
		$(".menu-subnumbers"+menu_pro_id).each (index) ->
			pro_id = $(this).attr('data-product-id')
			sum = 0
			$('.raw-product-'+pro_id).each ->
				menu_pid = $(this).attr('data-menu-pro-id')
				if ($('.menu-pro-check-'+menu_pid).is ":checked")
					mqty = $(this).val()
					mqty = parseFloat(mqty)
					sum = sum + mqty
				return
			current_stock = $('.estm-numbers'+pro_id).attr('data-current-stock')
			current_stock = parseFloat(current_stock)
			$('.estm-numbers'+pro_id).val(sum)
			if sum > current_stock
				$('.inefficient-raw-'+pro_id).html "Inefficient current stock"
				$('.error-counter-'+pro_id).val(1)
			else
				$('.inefficient-raw-'+pro_id).html ""
				$('.error-counter-'+pro_id).val(0)

		err_sum = 0;
		$('.err-counter-total').each ->
			err_sum = err_sum + $(this).val()
			return
		if err_sum > 0
			$('.new-production-btn').attr("disabled", true)
		else
			$('.new-production-btn').attr("disabled", false)
		return
		return

	$(document).on "click", ".transfer-options-btn",->
		$(".transfer-options-btn").hide()
		return
	$(document).on "click", ".show-template-btn",->
		temp_content =  "<div class='input-field m-input'>"
		temp_content += "<input type='text' class='validate' name='template_name' placeholder='Template name' required>"
		temp_content += "</div>"
		temp_content += "<button class='m-btn green width-100 waves-effect waves-light' type='submit'>Save and continue <i class='mdi-content-send right'></i></button>"
		$('#template-info').html temp_content
		return
	########### Function to add products to temporary cart without quantity###########
	$(document).on "change", ".add-products-to-cart-onkey",->
		item_name = $(this).data("product-name")
		product_id = $(this).data("product-id")
		Materialize.toast("#{item_name} selected.", 3000, 'rounded')
		return
	$(document).on "keyup change", ".add-products-to-cart-onkey",->
		stock_id = $(this).data("stock-id")
		product_id = $(this).data("product-id")
		item_name = $(this).data("product-name")
		item_unit = $(this).data("product-unit")
		item_sku = $(this).data("sku")
		item_quantity = $(".quantity_#{item_sku}").val()
		if $("#product_#{item_sku}").length
			$("#cart_item_#{item_sku}").val item_quantity
			$("#item_qty_#{item_sku}").html item_quantity
		else
			contentStr = "<li class='collection-item'><div>"
			contentStr += "<input type='checkbox' name='checked_products[]' value='#{stock_id}'/ id='product_#{item_sku}' checked>"
			contentStr += "<label for='product_#{product_id}' class='font-sz-11'>#{item_sku} - #{item_name}</label>"
			contentStr += "<span class='secondary-content font-sz-11'><span id='item_qty_#{item_sku}'>#{item_quantity}</span> #{item_unit}</span>"
			contentStr += "<input type='hidden' name='quantity#{stock_id}' value='#{item_quantity}' id='cart_item_#{item_sku}'/>"
			contentStr += "</div></li>"
			$(".no-item-selected").hide()
			$(".po-product-list").prepend(contentStr)
		if item_quantity <= 0
			$("#product_#{product_id}").prop('checked', false);
		else
			$("#product_#{product_id}").prop('checked', true);
		return

	$(document).on "keyup change", ".add-stock-products-to-cart-onkey",->
		stock_id = $(this).data("stock-id")
		product_id = $(this).data("product-id")
		item_name = $(this).data("product-name")
		item_unit = $(this).data("product-unit")
		item_sku = $(this).data("sku")
		color = $(this).data("product-color")
		size = $(this).data("product-size")
		price = $(this).data("product-price")
		model_number = $(this).data("product-model")
		batch_no = $(this).data("product-batch-no")
		item_quantity = $(this).val()
		console.log(color)
		console.log(size)
		class_and_id = "#{item_sku}_#{product_id}_#{color}_#{size}_#{parseInt(price)}"
		console.log($("#product_#{class_and_id}").length)

		if $("#product_#{class_and_id}").length
			console.log("length")
			$("#cart_quantity_#{class_and_id}").val item_quantity
			$("#item_qty_#{class_and_id}").text(item_quantity)
		else
			contentStr = "<li class='collection-item'><div>"
			contentStr += "<input type='checkbox' name='checked_products[]' value='#{stock_id}' id='product_#{class_and_id}' checked>"
			contentStr += "<label for='product_#{class_and_id}' class='font-sz-11'>#{item_sku} - #{item_name}</label>"
			contentStr += "<span class='secondary-content font-sz-11'><span id='item_qty_#{class_and_id}'>#{item_quantity}</span> #{item_unit}</span>"
			contentStr += "<input type='hidden' name='stock_audits[][product_id]' value='#{product_id}' id='cart_product_id_#{class_and_id}'/>"
			contentStr += "<input type='hidden' name='stock_audits[][quantity]' value='#{item_quantity}' id='cart_quantity_#{class_and_id}'/>"
			contentStr += "<input type='hidden' name='stock_audits[][sku]' value='#{item_sku}' id='cart_sku_#{class_and_id}'/>"
			contentStr += "<input type='hidden' name='stock_audits[][color_id]' value='#{color}' id='cart_color_id_#{class_and_id}'/>"
			contentStr += "<input type='hidden' name='stock_audits[][size_id]' value='#{size}' id='cart_size_id_#{class_and_id}'/>"
			contentStr += "<input type='hidden' name='stock_audits[][price]' value='#{price}' id='cart_price_#{class_and_id}'/>"
			contentStr += "<input type='hidden' name='stock_audits[][model_number]' value='#{model_number}' id='cart_model_no_#{class_and_id}'/>"
			contentStr += "<input type='hidden' name='stock_audits[][batch_no]' value='#{batch_no}' id='cart_batch_no_#{class_and_id}'/>"
			contentStr += "</div></li>"
			$(".no-item-selected").hide()
			$(".po-product-list").prepend(contentStr)
		if item_quantity <= 0
			$("#product_#{product_id}").prop('checked', false);
		else
			$("#product_#{product_id}").prop('checked', true);
		return

	$(document).on "keyup change", ".add-stock-identity-products-to-cart-onkey",->
		stock_id = $(this).data("stock-id")
		product_id = $(this).data("product-id")
		item_name = $(this).data("product-name")
		item_unit = $(this).data("product-unit")
		item_sku = $(this).data("sku")
		stock_identity = $(this).data("stock-identity")
		item_quantity = $(".quantity_#{stock_identity}").val()
		if $("#product_#{stock_id}").length
			$("#cart_item_#{stock_id}").val item_quantity
			$("#item_qty_#{stock_id}").html item_quantity
		else
			contentStr = "<li class='collection-item'><div>"
			contentStr += "<input type='checkbox' name='checked_products[]' value='#{stock_id}' id='product_#{stock_id}' checked>"
			contentStr += "<label for='product_#{stock_id}' class='font-sz-11'>#{stock_identity} - #{item_name}</label>"
			contentStr += "<span class='secondary-content font-sz-11'><span id='item_qty_#{stock_id}'>#{item_quantity}</span> #{item_unit}</span>"
			contentStr += "<input type='hidden' name='quantity#{stock_id}' value='#{item_quantity}' id='cart_item_#{stock_id}'/>"
			contentStr += "<input type='hidden' name='sku#{stock_id}' value='#{item_sku}' id='cart_sku_#{stock_id}'/>"
			contentStr += "</div></li>"
			$(".no-item-selected").hide()
			$(".po-product-list").prepend(contentStr)
		if item_quantity <= 0
			$("#product_#{stock_id}").prop('checked', false);
		else
			$("#product_#{stock_id}").prop('checked', true);
		return  

	$(document).on "change", ".add-products-to-audit",->
		item_name = $(this).data("product-name")
		product_id = $(this).data("product-id")
		Materialize.toast("#{item_name} selected.", 3000, 'rounded')
		return
	$(document).on "keyup change", ".add-products-to-audit",->
		product_id = $(this).data("product-id")
		item_name = $(this).data("product-name")
		item_unit = $(this).data("product-unit")
		item_quantity = $(".quantity_#{product_id}").val()
		if $("#product_#{product_id}").length
			$("#cart_item_quantity#{product_id}").val item_quantity
			$("#item_qty_#{product_id}").html item_quantity
		else
			contentStr = "<li class='collection-item'><div>"
			contentStr += "<input type='checkbox' name='checked_products[]' value='#{product_id}'/ id='product_#{product_id}' checked>"
			contentStr += "<label for='product_#{product_id}' class='font-sz-11'>#{item_name}</label>"
			contentStr += "<span class='secondary-content font-sz-11'><span id='item_qty_#{product_id}'>#{item_quantity}</span> #{item_unit}</span>"
			contentStr += "<input type='hidden' name='stock_audits[][product_id]' value='#{product_id}' id='cart_item_#{product_id}'/>"
			contentStr += "<input type='hidden' name='stock_audits[][quantity]' value='#{item_quantity}' id='cart_item_quantity#{product_id}'/>"
			contentStr += "</div></li>"
			$(".no-item-selected").hide()
			$(".po-product-list").prepend(contentStr)
		if item_quantity <= 0
			$("#product_#{product_id}").prop('checked', false);
		else
			$("#product_#{product_id}").prop('checked', true);
		return
	
	$(document).on "keyup change",".product_price", ->
		console.log("calculating price after chaning the unit price")
		product_id = $(this).data("product-id")
		price = parseFloat($(this).val())
		price = 0 if isNaN(price)
		quantity = parseFloat($(".transfer-quantity-#{product_id}").val())
		quantity = 0 if isNaN(quantity)
		estimated_price = price * quantity
		$(".estimated_cost_#{product_id}").val(estimated_price)
		return
	########### Function to calculate estimated cost #############################
	$(document).on "keyup change", ".input_quantity",->
		console.log("found")
		product_id = $(this).data("product-id")
		item_price = $(".price_#{product_id}").val()
		quantity = $(".transfer-quantity-#{product_id}").val()
		unit_input = $(".unit-input-#{product_id}").val()
		unit_input = unit_input.split("__") if typeof unit_input != 'undefined'
		multiplier = parseFloat(unit_input[2]) if typeof unit_input != 'undefined'
		multiplier = 1 if isNaN(multiplier)
		estimated_price = (item_price*quantity).toFixed(2)
		
		$(".estimated_cost_#{product_id}").val estimated_price

		return
	$(document).on "change keyup", ".add_transaction_unit", ->
		$("#cart_item_transaction_unit_#{$(this).data('product-id')}").val($(this).find(":selected").data("transaction-id"))
	$(document).on "keyup change", ".total_input_quantity",->
		product_id = $(this).data("product-id")
		item_price = $(".price_#{product_id}").val()
		quantity = $(".transfer-quantity-#{product_id}").val()
		unit_input = $(".unit-input-#{product_id}").val()
		unit_input = unit_input.split("__")
		multiplier = parseFloat(unit_input[2])
		multiplier = 1 if isNaN(multiplier)
		estimated_price = (item_price*quantity).toFixed(2)
		
		$(".estimated_cost_#{product_id}").val estimated_price
		$(".po_color_size_#{product_id}").val(0)
		$("#p_total_qty_#{product_id}").val(0)
		$(".li_color_size_product_#{product_id}").remove()

		return

	$(document).on "keyup change", ".transfer-input",->
		product_id = $(this).data("product-id")
		item_quantity = parseFloat($(".transfer-quantity-#{product_id}").val())
		unit_input = $(".unit-input-#{product_id}").val()
		unit_input = unit_input.split("__")
		item_name = $(this).data("product-name")
		if unit_input[0] > 0
			item_unit_id = unit_input[0]
			item_unit = unit_input[1]
		else
			item_unit_id = 0
			item_unit = $(this).data("basic-unit")
		if item_quantity <= 0 or isNaN(item_quantity)
			Materialize.toast("Please provide some quantity of #{item_name}.", 3000)
		else
			if $("#cart_item_#{product_id}").length
				$("#cart_item_#{product_id}").val item_quantity
				$("#item_qty_#{product_id}").html item_quantity
				$("#cart_item_unit_#{product_id}").val item_unit_id
				$("#item_unit_#{product_id}").html item_unit
			else
				contentStr = "<li class='collection-item'><div>"
				contentStr += "<input type='checkbox' name='checked_raw[]' value='#{product_id}' id='product_#{product_id}' checked>"
				contentStr += "<label for='product_#{product_id}' class='font-sz-11'>#{item_name}</label>"
				contentStr += "<span class='secondary-content font-sz-11'><span id='item_qty_#{product_id}'>#{item_quantity}</span> <span id='item_unit_#{product_id}'>#{item_unit}</span></span>"
				contentStr += "<input type='hidden' name='quantity#{product_id}' value='#{item_quantity}' id='cart_item_#{product_id}'/>"
				contentStr += "<input type='hidden' name='unit#{product_id}' value='#{item_unit_id}' id='cart_item_unit_#{product_id}'/>"
				contentStr += "</div></li>"
				$(".no-item-selected").hide()
				$(".po-product-list").append(contentStr)
		return

	$(document).on "keyup change", ".product_estmated_cose", ->
		product_id = $(this).data("product-id")
		quantity = $(".transfer-quantity-#{product_id}").val()
		estimated_cost = $(this).val()
		#unit_input = $(".unit-input-#{product_id}").val()
		#unit_input = unit_input.split("__")
		#multiplier = parseFloat(unit_input[2])
		#multiplier = 1 if isNaN(multiplier)
		#base_quantity = parseFloat(quantity*multiplier)
		#item_price = parseFloat(estimated_cost/base_quantity).toFixed(2)
		#item_price = parseFloat(estimated_cost / quantity).toFixed(2)
		item_price = parseFloat(estimated_cost / quantity).toFixed(2)
		$(".price_#{product_id}").val(item_price)
		return  

	$(document).on "keyup change", ".purchase-input",->

		product_id = $(this).data("product-id")
		$(".estimated_cost_#{product_id}").prop("disabled", false)
		item_price = $(".price_#{product_id}").val()
		vendor_product_id = $(this).data("vendor-product-id")
		item_quantity = parseFloat($(".transfer-quantity-#{product_id}").val())
		unit_input = $(".unit-input-#{product_id}").val()
		unit_input = unit_input.split("__")
		item_name = $(this).data("product-name")
		item_unit = $(this).data("basic-unit")
		business_type = $(this).data("business-type")
		product_transaction_id = $("#transaction_unit_#{product_id}").find(":selected").data("transaction-id")
		if product_transaction_id == undefined
			product_transaction_id = ''
		console.log(product_transaction_id)
		if unit_input[0] > 0
			item_unit_id = unit_input[0]
			item_unit = unit_input[1]
		else
			item_unit_id = 0
			item_unit = $(this).data("basic-unit")
		if item_quantity <= 0 or isNaN(item_quantity)
			Materialize.toast("Please provide some quantity of #{item_name}.", 3000)
			$(".po-product-list").find("#li_product_#{product_id}").remove()
		else
			$(this).removeClass 'error-input red'
			if $("#cart_item_#{product_id}").length
				$("#cart_item_#{product_id}").val item_quantity
				$("#item_qty_#{product_id}").html item_quantity
				$("#cart_item_unit_#{product_id}").val item_unit_id
				$("#item_unit_#{product_id}").html item_unit
				$("#cart_item_price_#{product_id}").val item_price
				$("#cart_item_transaction_unit_#{product_id}").val product_transaction_id
			else
				contentStr = "<li class='collection-item' id='li_product_#{product_id}'><div>"
				contentStr += "<input type='checkbox' name='checked_raw[]' value='#{product_id}' id='product_#{product_id}' checked>"
				contentStr += "<label for='product_#{product_id}' class='font-sz-11'>#{item_name}</label>"
				contentStr += "<span class='secondary-content font-sz-11'><span id='item_qty_#{product_id}'>#{item_quantity}</span> <span id='item_unit_#{product_id}'>#{item_unit}</span></span>"
				contentStr += "<input type='hidden' name='quantity#{product_id}' value='#{item_quantity}' id='cart_item_#{product_id}'/>"
				if business_type == "by_catalog" 
					contentStr += "<input type='hidden' name='price#{product_id}' value='#{item_price}' id='cart_item_price_#{product_id}'/>"
				contentStr += "<input type='hidden' name='vendor_product_id#{product_id}' value='#{vendor_product_id}' id='cart_item_vendor_product_id#{product_id}'>"
				contentStr += "<input type='hidden' name='unit#{product_id}' value='#{item_unit_id}' id='cart_item_unit_#{product_id}'/>"
				contentStr += "<input type='hidden' name='transaction_unit_#{product_id}' value='#{product_transaction_id}' id='cart_item_transaction_unit_#{product_id}'/>"
				contentStr += "</div></li>"
				$(".no-item-selected").hide()
				$(".po-product-list").prepend(contentStr)
		return

	########### Function of product_color_size #############
	$(document).on "keyup change", ".product_color_size",->
		product_id = $(this).data("product-id")
		$(".estimated_cost_#{product_id}").prop("disabled", false)
		color_id = $(this).data("color-id")
		color_name = $(this).data("color-name")
		size_id = $(this).data("size-id")
		size_name = $(this).data("size-name")
		quantity = $(this).val()
		total_quantity = 0

		unit_input = $(".unit-input-#{product_id}").val()
		unit_input = unit_input.split("__")
		multiplier = parseFloat(unit_input[2])
		multiplier = 1 if isNaN(multiplier)
		item_name = $(this).data("product-name")
		item_price = $(".price_#{product_id}").val()
		vendor_product_id = $(this).data("vendor-product-id")
		item_unit = $(this).data("basic-unit")
		business_type = $(this).data("business-type")

		$("#li_product_#{product_id}").remove()

		if unit_input[0] > 0
			item_unit_id = unit_input[0]
			item_unit = unit_input[1]
		else
			item_unit_id = 0
			item_unit = $(this).data("basic-unit")
		
		$(".po_color_size_#{product_id}").each ->
			if $(this).val().length
				total_quantity += parseFloat($(this).val())
			$(".transfer-quantity-#{product_id}").val(total_quantity)
			$("#p_total_qty_#{product_id}").val total_quantity
			return

		estimated_price = (item_price*total_quantity).toFixed(2)
		$(".estimated_cost_#{product_id}").val estimated_price

		if quantity <= 0 or isNaN(quantity)
			Materialize.toast("Please provide some quantity of #{item_name}.", 3000)
			$(".po-product-list").find("#li_product_#{product_id}_#{color_id}_#{size_id}").remove()
		else
			$(".transfer-quantity-#{product_id}").removeClass 'error-input red'
			if $("#cart_item_#{product_id}_#{color_id}_#{size_id}").length
				$("#cart_item_#{product_id}_#{color_id}_#{size_id}").val quantity
				$("#item_qty_#{product_id}_#{color_id}_#{size_id}").html quantity
				$("#item_unit_#{product_id}_#{color_id}_#{size_id}").html item_unit
				$("#product_#{product_id}_#{color_id}_#{size_id}").data 'quantity', quantity
			else
				contentStr = "<li class='collection-item li_color_size_product_#{product_id}' id='li_product_#{product_id}_#{color_id}_#{size_id}'><div>"
				contentStr += "<input type='checkbox' class='checked_raw_single_product' name='checked_raw_single_product[]' value='#{product_id}_#{color_id}_#{size_id}' id='product_#{product_id}_#{color_id}_#{size_id}' data-product-id='#{product_id}' data-quantity='#{quantity}' checked>"
				if "#{color_name}"=='undefined'
					contentStr += "<label for='product_#{product_id}_#{color_id}_#{size_id}' class='font-sz-11'>#{item_name}-#{size_name}</label>"
				else if "#{size_name}" == 'undefined'
					contentStr += "<label for='product_#{product_id}_#{color_id}_#{size_id}' class='font-sz-11'>#{item_name}-#{color_name}</label>"
				else
					contentStr += "<label for='product_#{product_id}_#{color_id}_#{size_id}' class='font-sz-11'>#{item_name}-#{color_name}-#{size_name}</label>"
				contentStr += "<span class='secondary-content font-sz-11'><span id='item_qty_#{product_id}_#{color_id}_#{size_id}'>#{quantity}</span> <span id='item_unit_#{product_id}_#{color_id}_#{size_id}'>#{item_unit}</span></span>"
				contentStr += "<input type='hidden' name='single_item_quantity#{product_id}_#{color_id}_#{size_id}' value='#{quantity}' id='cart_item_#{product_id}_#{color_id}_#{size_id}'/>"
				
				contentStr += "</div></li>"
				$(".no-item-selected").hide()
				$(".po-product-list").prepend(contentStr)

		# if $(".product_color_size_quantity_#{product_id}_#{color_id}_#{size_id}").length
		#   $(".product_color_size_quantity_#{product_id}_#{color_id}_#{size_id}").val quantity
		# else
		#   singleItemContentStr = "<input type='checkbox' class='checked_product_color_size_#{product_id}_#{color_id}_#{size_id}' name='checked_raw_color_size_product_#{product_id}[]' value='#{color_id}_#{size_id}' checked>"
		#   singleItemContentStr += "<input type='hidden' class='product_color_size_quantity_#{product_id}_#{color_id}_#{size_id}' name='product_color_size_quantity_#{product_id}_#{color_id}_#{size_id}' value='#{quantity}'>"

		#   $("#li_product_#{product_id}_#{color_id}_#{size_id}").prepend(singleItemContentStr)
		
		if total_quantity <= 0 or isNaN(total_quantity)
			Materialize.toast("Please provide some quantity of #{item_name}.", 3000)
			$(".po-product-list").find("#li_product_#{product_id}").remove()
		else
			$(".transfer-quantity-#{product_id}").removeClass 'error-input red'
			if $("#cart_item_#{product_id}").length
				$("#cart_item_#{product_id}").val total_quantity
				$("#cart_item_unit_#{product_id}").val item_unit_id
				$("#cart_item_price_#{product_id}").val item_price
			else

				totalContentStr = "<li style='display:none;' class='collection-item' id='li_product_#{product_id}'><div>"
				totalContentStr += "<input type='checkbox' name='checked_raw[]' value='#{product_id}' id='product_#{product_id}' checked>"

				totalContentStr += "<input type='hidden' name='quantity#{product_id}' value='#{total_quantity}' id='cart_item_#{product_id}'/>"
				if business_type == "by_catalog" 
					totalContentStr += "<input type='hidden' name='price#{product_id}' value='#{item_price}' id='cart_item_price_#{product_id}'/>"
				totalContentStr += "<input type='hidden' name='vendor_product_id#{product_id}' value='#{vendor_product_id}' id='cart_item_vendor_product_id#{product_id}'>"
				totalContentStr += "<input type='hidden' name='unit#{product_id}' value='#{item_unit_id}' id='cart_item_unit_#{product_id}'/>"

				# $("#li_product_#{product_id}").prepend(totalContentStr)
				$(".po-product-list").prepend(totalContentStr)

		return 

	$(document).on "click", ".checked_raw_single_product" ,->
		product_color_size_id = $(this).val()
		product_id = $(this).data('product-id')
		quantity = $(this).data('quantity')
		old_total_quantity = $("#p_total_qty_#{product_id}").val()
		unit_input = $(".unit-input-#{product_id}").val()
		unit_input = unit_input.split("__")
		multiplier = parseFloat(unit_input[2])
		multiplier = 1 if isNaN(multiplier)
		item_price = $(".price_#{product_id}").val()
		
		if !$(this).is(':checked')
			new_total_quantity = parseFloat(old_total_quantity) - parseFloat(quantity)
			$(".po_color_size_#{product_color_size_id}").val 0
		else
			new_total_quantity = parseFloat(old_total_quantity) + parseFloat(quantity)
			$(".po_color_size_#{product_color_size_id}").val quantity
			
		$("#cart_item_#{product_id}").val new_total_quantity
		$(".transfer-quantity-#{product_id}").val new_total_quantity
		$("#p_total_qty_#{product_id}").val new_total_quantity

		estimated_price = (item_price*new_total_quantity).toFixed(2)
		$(".estimated_cost_#{product_id}").val estimated_price

		return

	########### Function of simo #############
	$(document).on "click", ".output_selected_product" ,->
		$(".product_check#{$(this).val()}").remove()
		$(".simo_output_#{$(this).val()}").prop 'checked', false
		return  

	$(document).on "click", ".simo-output" ,->
		conjugated_unit = $(".conjugated_unit").val()
		product_id = $(this).data("product-id")
		item_name = $(this).data("product-name")
		item_unit = $(this).data("product-unit")
		if $(this).prop('checked')
			if $("tr").hasClass("product_check#{product_id}")
				Materialize.toast("Product already selected for SIMO.", 6000,'red')
				$(this).prop 'checked', false
			else
				$("#wastage").show()
				contentString = "<tr class='data-table__selectable-row product_check#{product_id}'>"
				contentString += "<td>"
				contentString += "<input type='checkbox' name= 'checked_raw[]' value= '#{product_id}' id = 'product#{product_id}' class= 'output_selected_product' checked>"
				contentString += "<label for='product#{product_id}' class='font-sz-11'>#{item_name}</label>"
				contentString += "</td>" 
				contentString += "<td class='m-input'><div class='secondary-content row margin-l-r-none'><div class='col-lg-9 padding-l-r-none'><input type='text' class='expected_quantity' name='expected_quantity#{product_id}' placeholder='exp qty'/></div><div class='col-lg-3 padding-l-r-none'><br>#{item_unit}</div></div></td>"
				#contentString += "<td class='m-input'><div class='secondary-content row margin-l-r-none'><div class='col-lg-9 padding-l-r-none'><input type='text' class='actual_quantity' name='actual_quantity#{product_id}' placeholder='act qty'/></div><div class='col-lg-3 padding-l-r-none'><br>#{item_unit}</div></div></td>" 
				contentString += "<td class='m-input'><div class='secondary-content row margin-l-r-none'><div class='col-lg-9 padding-l-r-none'><input type='text' class='price' name='price#{product_id}' placeholder='Price'/></div></div></td>"       
				#contentString += "<td class='m-input'><div class='secondary-content row margin-l-r-none'><div class='col-lg-9 padding-l-r-none'><input type='text' class='weight_amount' name='weight#{product_id}' placeholder='weight'/></div><div class='col-lg-3 padding-l-r-none'><br>#{conjugated_unit}</div></div></td>" 
				contentString += "</tr>"
		else  
			$("#output_product").find(".product_check#{product_id}").remove()
		$(".no-item-selected").hide()
		$("#output_product").prepend(contentString)
		return  

	$(document).on "keyup change", ".weight_amount", ->
		conjugated_unit = $(".conjugated_unit").val()
		total_input = $(".input_product").val()
		val = 0
		$('.weight_amount').each ->
			if $(this).val() != ""
				val += parseFloat($(this).val())
		if val > parseFloat(total_input)
			Materialize.toast("Wastage is greater than input val.", 6000,'red')
			$(this).val ''
		else    
			wastage = (parseFloat(total_input) - val).toFixed(2) 
			$("#wastage_amount").html ''
			$("#wastage_amount").html wastage+conjugated_unit
		return  

	$(document).on "click", ".initiate_simo",(event) ->
		flag = 0
		$('.price').each ->
			if $(this).val() == ""
				flag = 1
			if flag == 1
				Materialize.toast("Enter Price.", 6000,'red')
				event.preventDefault()
		return

	$(document).on "click", ".initiate_simo",(event) ->
		flag = 0
		$('.expected_quantity').each ->
			if $(this).val() == ""
				flag = 1
			if flag == 1
				Materialize.toast("Enter Expected quantity.", 6000,'red')
				event.preventDefault()
		return

	$(document).on "click", ".finished_simo",(event) -> 
		flag = 0
		$('.weight_amount').each ->
			if $(this).val() == ""
				flag = 1
			if flag == 1
				Materialize.toast("Enter Total weight.", 6000,'red')
				event.preventDefault()
		return 
	
	$(document).on "click", ".finished_simo",(event) -> 
		flag = 0
		$('.actual_quantity').each ->
			if $(this).val() == ""
				flag = 1
			if flag == 1
				Materialize.toast("Enter Actual quantity.", 6000,'red')
				event.preventDefault()
		return 

	$(document).on 'keyup change', '.simo_qty',->
		$('.simo_qty').prop("disabled",true)
		$(this).prop("disabled",false)
		$(this).focus()
		product_id = $(this).data("product-id")
		item_quantity = parseFloat($(".simo_quantity_#{product_id}").val())
		item_name = $(this).data("product-name")
		current_stock = $(this).data("current-stock")
		item_unit = $(this).data("conjugated-unit")
		if item_quantity <= 0 or isNaN(item_quantity)
			$('.simo_qty').prop("disabled",false)
			Materialize.toast("Please provide some quantity of #{item_name}.", 3000)
			$(".po-product-list").find("#li_product_#{product_id}").remove()
		else if item_quantity > current_stock
			$(this).addClass 'error-input red'
			Materialize.toast("#{item_quantity} #{item_unit} of #{item_name} are not available.", 6000,'red')
			$(".po-product-list").find("#li_product_#{product_id}").remove()
		else
			$(this).removeClass 'error-input red'
			if $("#cart_item_#{product_id}").length
				$("#cart_item_#{product_id}").val item_quantity
				$("#item_qty_#{product_id}").html item_quantity
				$("#cart_item_unit_#{product_id}").val item_unit_id
				$("#item_unit_#{product_id}").html item_unit
			else
				contentStr = "<li class='collection-item' id='li_product_#{product_id}'><div>"
				contentStr += "<input type='checkbox' name= 'checked_raw[]' value= '#{product_id}' id = 'product_#{product_id}' checked>"
				contentStr += "<label for='product_#{product_id}' class='font-sz-11'>#{item_name}</label>"
				contentStr += "<span class='secondary-content font-sz-11'><span id='item_qty_#{product_id}'>#{item_quantity}</span> <span id='item_unit_#{product_id}'>#{item_unit}</span></span>"
				contentStr += "<input type='hidden' name='quantity#{product_id}' value='#{item_quantity}' id='cart_item_#{product_id}' class='cart_item'/>"
				contentStr += "</div></li>"
				$(".no-item-selected").hide()
				$(".po-product-list").prepend(contentStr)
		return

########### Function to add products to temporary cart with quantity###########
	$(document).on "click", ".add-products-to-temp-cart",->
		product_id = $(this).data("product-id")
		item_name = $(this).data("product-name")
		item_unit = $(this).data("product-unit")
		vendor_id = $(this).data("vendor-id")
		item_quantity = $(".quantity_#{product_id}").val()
		item_price = $(".price_#{product_id}").val()
		if item_quantity <= 0
			Materialize.toast("OOPS! Please provide some quantity of #{item_name}.", 3000)
		else
			if $("#cart_item_#{product_id}").length
				Materialize.toast("#{item_name} updated.", 3000, 'rounded')
				$("#cart_item_#{product_id}").val item_quantity
				$("#item_qty_#{product_id}").html item_quantity
			else
				Materialize.toast("#{item_name} selected.", 3000, 'rounded')
				contentStr = "<li class='collection-item'><div>"
				contentStr += "<input type='checkbox' name='checked_raw[]' value='#{product_id}'/ id='product_#{product_id}' checked>"
				contentStr += "<label for='product_#{product_id}' class='font-sz-11'>#{item_name}</label>"
				contentStr += "<span class='secondary-content font-sz-11'><span id='item_qty_#{product_id}'>#{item_quantity}</span> #{item_unit}</span>"
				contentStr += "<input type='hidden' name='quantity#{product_id}' value='#{item_quantity}' id='cart_item_#{product_id}'/>"
				# contentStr += "<input type='hidden' name='checked_raw[]' value='#{product_id}'/>"
				contentStr += "</div></li>"
				$(".no-item-selected").hide()
				$(".po-product-list").append(contentStr)
		return

	$(document).on "keyup", ".requisition-product-total-quantity",->
		product_id = $(this).data("product-id")
		item_name = $(this).data("product-name")
		item_unit = $(this).data("product-unit")
		vendor_id = $(this).data("vendor-id")
		item_quantity = $(".requisition_quantity_#{product_id}").val()
		item_price = $(".price_#{product_id}").val()

		$(".rq_color_size_#{product_id}").val(0)
		$("#p_total_qty_#{product_id}").val(0)
		$(".li_color_size_product_#{product_id}").remove()

		if item_quantity <= 0
			Materialize.toast("OOPS! Please provide some quantity of #{item_name}.", 3000)
			$(".rq-product-list").find("#li_product_#{product_id}").remove()
		else
			if $("#cart_item_#{product_id}").length
				Materialize.toast("#{item_name} updated.", 3000, 'rounded')
				$("#cart_item_#{product_id}").val item_quantity
				$("#item_qty_#{product_id}").html item_quantity
			else
				Materialize.toast("#{item_name} selected.", 3000, 'rounded')
				contentStr = "<li class='collection-item' id='li_product_#{product_id}'><div>"
				contentStr += "<input type='checkbox' name='checked_raw[]' value='#{product_id}'/ id='product_#{product_id}' checked>"
				contentStr += "<label for='product_#{product_id}' class='font-sz-11'>#{item_name}</label>"
				contentStr += "<span class='secondary-content font-sz-11'><span id='item_qty_#{product_id}'>#{item_quantity}</span> #{item_unit}</span>"
				contentStr += "<input type='hidden' name='quantity#{product_id}' value='#{item_quantity}' id='cart_item_#{product_id}'/>"
				# contentStr += "<input type='hidden' name='checked_raw[]' value='#{product_id}'/>"
				contentStr += "</div></li>"
				$(".no-item-selected").hide()
				$(".rq-product-list").append(contentStr)
		return

	########### Function of requisition product_color_size #############
	$(document).on "keyup change", ".rq_product_color_size",->
		product_id = $(this).data("product-id")
		color_id = $(this).data("color-id")
		color_name = $(this).data("color-name")
		size_id = $(this).data("size-id")
		size_name = $(this).data("size-name")
		quantity = $(this).val()
		total_quantity = 0

		item_name = $(this).data("product-name")
		item_unit = $(this).data("basic-unit")
		business_type = $(this).data("business-type")

		$("#li_product_#{product_id}").remove()

		item_unit_id = 0
		
		$(".rq_color_size_#{product_id}").each ->
			if $(this).val().length
				total_quantity += parseFloat($(this).val())
			$(".requisition_quantity_#{product_id}").val(total_quantity)
			$("#p_total_qty_#{product_id}").val total_quantity
			return

		if quantity <= 0 or isNaN(quantity)
			Materialize.toast("Please provide some quantity of #{item_name}.", 3000)
			$(".rq-product-list").find("#li_product_#{product_id}_#{color_id}_#{size_id}").remove()
		else
			$(".requisition_quantity_#{product_id}").removeClass 'error-input red'
			if $("#cart_item_#{product_id}_#{color_id}_#{size_id}").length
				$("#cart_item_#{product_id}_#{color_id}_#{size_id}").val quantity
				$("#item_qty_#{product_id}_#{color_id}_#{size_id}").html quantity
				$("#product_#{product_id}_#{color_id}_#{size_id}").data 'quantity', quantity
			else
				contentStr = "<li class='collection-item li_color_size_product_#{product_id}' id='li_product_#{product_id}_#{color_id}_#{size_id}'><div>"
				contentStr += "<input type='checkbox' class='checked_raw_single_product' name='checked_raw_single_product[]' value='#{product_id}_#{color_id}_#{size_id}' id='product_#{product_id}_#{color_id}_#{size_id}' data-product-id='#{product_id}' data-quantity='#{quantity}' checked>"
				if "#{color_name}"=='undefined'
					contentStr += "<label for='product_#{product_id}_#{color_id}_#{size_id}' class='font-sz-11'>#{item_name}-#{size_name}</label>"
				else if "#{size_name}" == 'undefined'
					contentStr += "<label for='product_#{product_id}_#{color_id}_#{size_id}' class='font-sz-11'>#{item_name}-#{color_name}</label>"
				else
					contentStr += "<label for='product_#{product_id}_#{color_id}_#{size_id}' class='font-sz-11'>#{item_name}-#{color_name}-#{size_name}</label>"
				contentStr += "<span class='secondary-content font-sz-11'><span id='item_qty_#{product_id}_#{color_id}_#{size_id}'>#{quantity}</span>#{item_unit}</span>"
				contentStr += "<input type='hidden' name='single_item_quantity#{product_id}_#{color_id}_#{size_id}' value='#{quantity}' id='cart_item_#{product_id}_#{color_id}_#{size_id}'/>"
				
				contentStr += "</div></li>"
				$(".no-item-selected").hide()
				$(".rq-product-list").prepend(contentStr)

		# if $(".rq_product_color_size_quantity_#{product_id}_#{color_id}_#{size_id}").length
		#   $(".rq_product_color_size_quantity_#{product_id}_#{color_id}_#{size_id}").val quantity
		# else
		#   singleItemContentStr = "<input type='checkbox' class='checked_rq_product_color_size_#{product_id}_#{color_id}_#{size_id}' name='checked_raw_color_size_product_#{product_id}[]' value='#{color_id}_#{size_id}' checked>"
		#   singleItemContentStr += "<input type='hidden' class='rq_product_color_size_quantity_#{product_id}_#{color_id}_#{size_id}' name='rq_product_color_size_quantity_#{product_id}_#{color_id}_#{size_id}' value='#{quantity}'>"

		#   $("#li_product_#{product_id}_#{color_id}_#{size_id}").prepend(singleItemContentStr)
		
		# if total_quantity <= 0 or isNaN(total_quantity)
		# 	Materialize.toast("Please provide some quantity of #{item_name}.", 3000)
		# 	$(".po-product-list").find("#li_product_#{product_id}").remove()
		# else
		# 	$(".transfer-quantity-#{product_id}").removeClass 'error-input red'
		# 	if $("#cart_item_#{product_id}").length
		# 		$("#cart_item_#{product_id}").val total_quantity
		# 		$("#cart_item_unit_#{product_id}").val item_unit_id
		# 		$("#cart_item_price_#{product_id}").val item_price
		# 	else

		# 		totalContentStr = "<li style='display:none;' class='collection-item' id='li_product_#{product_id}'><div>"
		# 		totalContentStr += "<input type='checkbox' name='checked_raw[]' value='#{product_id}' id='product_#{product_id}' checked>"

		# 		totalContentStr += "<input type='hidden' name='quantity#{product_id}' value='#{total_quantity}' id='cart_item_#{product_id}'/>"
		# 		if business_type == "by_catalog" 
		# 			totalContentStr += "<input type='hidden' name='price#{product_id}' value='#{item_price}' id='cart_item_price_#{product_id}'/>"
		# 		totalContentStr += "<input type='hidden' name='vendor_product_id#{product_id}' value='#{vendor_product_id}' id='cart_item_vendor_product_id#{product_id}'>"
		# 		totalContentStr += "<input type='hidden' name='unit#{product_id}' value='#{item_unit_id}' id='cart_item_unit_#{product_id}'/>"

		# 		# $("#li_product_#{product_id}").prepend(totalContentStr)
		# 		$(".po-product-list").prepend(totalContentStr)

		return 


	$(document).on "keyup change", ".transfer_qty", ->
		console.log("this is  me")
		quentity = $(this).val()
		product_id = $(this).data("product-id")
		product_name = $(this).data("product-name")
		current_stock = $(this).data("current-stock")
		transfer_in  = $(this).parent().next().children()		
		if  transfer_in.find("option:selected").data("product-unit-id") == undefined
			transfer_in = ""
		else
			transfer_in = transfer_in.find("option:selected").data("product-unit-id")
		console.log(transfer_in)
		if($(this).parent().next().children().find("option:selected").val())
			current_stock = current_stock/$(this).parent().next().children().find("option:selected").val()
			console.log(current_stock)
		if quentity > current_stock
			$(this).addClass 'error-input red'
			Materialize.toast("#{quentity} of #{product_name} are not available.", 4000,'red')
			$("#product_ids").find(".product_#{product_id}").remove()
			$(".token-input-list-facebook").find(".product-token-#{product_id}").remove()
			$(".transfer_quantity_#{product_id}").val('')
		else if quentity <= 0
			$(this).addClass 'error-input red'
			Materialize.toast("Transfer quantity must be greater than 0.", 3000,'red')
			$("#product_ids").find(".product_#{product_id}").remove()
			$(".token-input-list-facebook").find(".product-token-#{product_id}").remove()
			#$(".transfer_quantity_#{product_id}").val('')
		else
			$(this).removeClass 'error-input red'  
			if $("#product_token_#{product_id}").length
				$("#quentity_#{product_id}").val(quentity)
			else
				product = "<input type='hidden' class='product_#{product_id}' name='product_id' value='#{product_id}'>"
				contentStr = "<li class='token-input-token-facebook product-token-#{product_id}' id='product_token_#{product_id}'>"
				contentStr += "<p>#{product_name}</p>"
				contentStr += "<span class='token-input-delete-token-facebook delete-product-token' data-product-id='#{product_id}'>×</span>"
				contentStr += "<input type='hidden' name='quentity#{product_id}' value='#{quentity}' id='quentity_#{product_id}'/>"
				contentStr += "<input type='hidden' name='transfered_in#{product_id}' value='#{transfer_in}' id='transfer_in_#{product_id}'/>"
				contentStr += "</li>"  
				$('.token-input-list-facebook').find(' > li:nth-last-child(1)').before(contentStr)
				$("#product_ids").append(product)
		return  


	$(document).on "keyup", ".sku_transfer_qty", ->
		sku = $(this).data("sku")
		quentity = $(this).val()
		product_id = $(this).data("product-id")
		product_name = $(this).data("product-name")
		current_stock = $(this).data("current-stock")
		sale_price_without_tax = $(this).data("sell-price-without-tax")
		expiry_date = $(this).data("expiry-date")  
		mrp = $(this).data("mrp")  
		model_number = $(this).data("model-number")
		size = $(this).data("size")
		procurment_price = $(this).data("procurment-price")
		color_name = $(this).data("color-name")
		color_id = $(this).data("color-id")
		size_id = $(this).data("size-id")
		batch_no = $(this).data("batch-no")
		transfer_in  = $(this).parent().next().children()		
		if  transfer_in.find("option:selected").data("product-unit-id") == undefined
			transfer_in = ""
		else
			transfer_in = transfer_in.find("option:selected").data("product-unit-id")
		console.log("transfered in #{transfer_in}")
		if ($(this).parent().next().children().find("option:selected").val())
			current_stock = current_stock / $(this).parent().next().children().find("option:selected").val()
		if quentity > current_stock
			$(this).addClass 'error-input red'
			Materialize.toast("#{quentity} #{transfer_in} of #{product_name}-(#{sku}) are not available.", 4000,'red')
			$("#product_ids").find(".product_#{sku}").remove()
			$(".token-input-list-facebook").find(".product-token-#{sku}").remove()
			$(".transfer_quantity_#{sku}").val('')
		else if quentity <= 0
			$(this).addClass 'error-input red'
			Materialize.toast("Transfer quantity must be greater than 0.", 3000,'red')
			$("#product_ids").find(".product_#{sku}").remove()
			$(".token-input-list-facebook").find(".product-token-#{sku}").remove()
			#$(".transfer_quantity_#{sku}").val('')
		else
			$(this).removeClass 'error-input red'  
			if $("#product_token_#{sku}").length
				$("#quentity_#{sku}").val(parseFloat($("#quentity_#{sku}").val())+parseFloat(quentity))
			else
				product = "<input type='hidden' class='product_#{sku}' name='product_id' value='#{sku}'>"
				contentStr = "<li class='token-input-token-facebook product-token-#{sku}' id='product_token_#{sku}'>"
				contentStr += "<p>#{product_name}-(#{sku})</p>"
				contentStr += "<input type='hidden' name='checked_sku[]' value='#{sku}' id='product_#{sku}'>"
				contentStr += "<span class='token-input-delete-token-facebook delete-sku-token' data-product-sku='#{sku}'>×</span>"
				contentStr += "<input type='hidden' name='quentity#{sku}' value='#{quentity}' id='quentity_#{sku}'/>"
				contentStr += "<input type='hidden' name='product_id#{sku}' value='#{product_id}'/>"
				contentStr += "<input type='hidden' name='expiry_date#{sku}' value='#{expiry_date}'/>"
				contentStr += "<input type='hidden' name='sale_price_without_tax#{sku}' value='#{sale_price_without_tax}'/>"
				contentStr += "<input type='hidden' name='mrp#{sku}' value='#{mrp}'/>"
				contentStr += "<input type='hidden' name='model_number#{sku}' value='#{model_number}'/>"
				contentStr += "<input type='hidden' name='size#{sku}' value='#{size}'/>"
				contentStr += "<input type='hidden' name='color_name#{sku}' value='#{color_name}'/>"
				contentStr += "<input type='hidden' name='procurment_price#{sku}' value='#{procurment_price}'/>"
				contentStr += "<input type='hidden' name='color_id#{sku}' value='#{color_id}'/>"
				contentStr += "<input type='hidden' name='size_id#{sku}' value='#{size_id}'/>"
				contentStr += "<input type='hidden' name='batch_no#{sku}' value='#{batch_no}'/>"
				contentStr += "<input type='hidden' name='transfered_in#{sku}' value='#{transfer_in}'/>"
				contentStr += "</li>"  
				$('.token-input-list-facebook').find(' > li:nth-last-child(1)').before(contentStr)
				$("#product_ids").append(product)
		 
		return    

	$(document).on "keyup change", ".stock_identity_transfer_qty", ->
		sku = $(this).data("sku")

		stock_id = $(this).data("stock-id")
		#alert stock_id
		stock_identity = $(this).data("stock_identity")
		quentity = $(this).val()
		product_id = $(this).data("product-id")
		product_name = $(this).data("product-name")
		current_stock = $(this).data("current-stock")
		sale_price_without_tax = $(this).data("sell-price-without-tax")
		expiry_date = $(this).data("expiry-date")  
		mrp = $(this).data("mrp")  
		model_number = $(this).data("model-number")
		size = $(this).data("size")
		procurment_price = $(this).data("procurment-price")
		color_name = $(this).data("color-name")
		color_id = $(this).data("color-id")
		size_id = $(this).data("size-id")
		batch_no = $(this).data("batch-no")
		transfer_in  = $(this).parent().next().children()		
		if  transfer_in.find("option:selected").data("product-unit-id") == undefined
			transfer_in = ""
		else
			transfer_in = transfer_in.find("option:selected").data("product-unit-id")
		console.log("transfered in #{transfer_in}")
		if ($(this).parent().next().children().find("option:selected").val())
			current_stock = current_stock / $(this).parent().next().children().find("option:selected").val()
		if quentity > current_stock
			$(this).addClass 'error-input red'
			Materialize.toast("#{quentity} #{transfer_in} of #{product_name}-(#{stock_id}) are not available.", 4000,'red')
			$("#product_ids").find(".product_#{stock_id}").remove()
			$(".token-input-list-facebook").find(".product-token-#{stock_id}").remove()
			$(".transfer_quantity_#{stock_id}").val('')
		else if quentity <= 0
			$(this).addClass 'error-input red'
			Materialize.toast("Transfer quantity must be greater than 0.", 3000,'red')
			$("#product_ids").find(".product_#{stock_id}").remove()
			$(".token-input-list-facebook").find(".product-token-#{stock_id}").remove()
			$(".transfer_quantity_#{stock_id}").val('')
		else
			$(this).removeClass 'error-input red'  
			if $("#product_token_#{stock_id}").length
				$("#quentity_#{stock_id}").val(quentity)
			else
				product = "<input type='hidden' class='product_#{stock_id}' name='product_id' value='#{stock_id}'>"
				contentStr = "<li class='token-input-token-facebook product-token-#{stock_id}' id='product_token_#{stock_id}'>"
				contentStr += "<p>#{product_name}-(#{stock_identity})</p>"
				contentStr += "<input type='hidden' name='checked_stock_id[]' value='#{stock_id}' id='product_#{stock_id}'>"
				contentStr += "<span class='token-input-delete-token-facebook delete-stock-identity-token' data-product-stock-identity='#{stock_id}'>×</span>"
				contentStr += "<input type='hidden' name='quentity#{stock_id}' value='#{quentity}' id='quentity_#{stock_id}'/>"
				contentStr += "<input type='hidden' name='sku#{stock_id}' value='#{sku}' id='sku_#{stock_id}'/>"
				contentStr += "<input type='hidden' name='stock_identity#{stock_id}' value='#{stock_identity}' id='stock_identity_#{stock_id}'/>"
				contentStr += "<input type='hidden' name='product_id#{stock_id}' value='#{product_id}'/>"
				contentStr += "<input type='hidden' name='expiry_date#{stock_id}' value='#{expiry_date}'/>"
				contentStr += "<input type='hidden' name='sale_price_without_tax#{stock_id}' value='#{sale_price_without_tax}'/>"
				contentStr += "<input type='hidden' name='mrp#{stock_id}' value='#{mrp}'/>"
				contentStr += "<input type='hidden' name='model_number#{stock_id}' value='#{model_number}'/>"
				contentStr += "<input type='hidden' name='size#{stock_id}' value='#{size}'/>"
				contentStr += "<input type='hidden' name='color_name#{stock_id}' value='#{color_name}'/>"
				contentStr += "<input type='hidden' name='procurment_price#{stock_id}' value='#{procurment_price}'/>"
				contentStr += "<input type='hidden' name='color_id#{stock_id}' value='#{color_id}'/>"
				contentStr += "<input type='hidden' name='size_id#{stock_id}' value='#{size_id}'/>"
				contentStr += "<input type='hidden' name='batch_no#{stock_id}' value='#{batch_no}'/>"
				contentStr += "<input type='hidden' name='transfered_in#{stock_id}' value='#{transfer_in}'/>"
				contentStr += "</li>"  
				$('.token-input-list-facebook').find(' > li:nth-last-child(1)').before(contentStr)
				$("#product_ids").append(product)
		 
		return    


	$(document).on 'click', '.initiate-transfer', ->
		if $("#stock_transfer_transfer_type").val() == ''
			Materialize.toast("Select transfer type first.", 3000)
			return false
		else  
			$('input[name^="product_id"]').each ->
				cur_val = $('input#stock_transfer_product_tokens').val()
				product_id = $(this).val()
				if (cur_val && product_id)
					$('input#stock_transfer_product_tokens').val(cur_val + "," + product_id)
				else if(cur_val)
					$('input#stock_transfer_product_tokens').val(cur_val)
				else
					$('input#stock_transfer_product_tokens').val(product_id)    
				return  
		return 

	$(document).on 'click', '.delete-product-token', ->
		product_id = $(this).data("product-id")
		$(".token-input-list-facebook").find(".product-token-#{product_id}").remove()
		$("#product_ids").find(".product_#{product_id}").remove()
		$(".transfer_quantity_#{product_id}").val('')
		return     

	$(document).on 'click', '.delete-sku-token', ->
		sku = $(this).data("product-sku")
		$(".token-input-list-facebook").find(".product-token-#{sku}").remove()
		$("#product_ids").find(".product_#{sku}").remove()
		$(".transfer_quantity_#{sku}").val('')
		return 

	$(document).on 'click', '.delete-stock-identity-token', ->
		stock_id = $(this).data("product-stock-identity")
		$(".token-input-list-facebook").find(".product-token-#{stock_id}").remove()
		$("#product_ids").find(".product_#{stock_id}").remove()
		$(".transfer_quantity_#{stock_id}").val('')
		return 	  
		
	# Stock audit quantity validation
	$('.stock-input').on "keyup change", ->
		pro_id = $(this).attr('data-product-id')
		qanty = parseFloat($(this).val())
		avble = parseFloat($(this).attr('data-stock-available'))
		if qanty > avble
			$(this).val(avble)
		pro_available_qty = 0
		pro_input_qty = 0
		$(".product-stocks-"+pro_id).each (index) ->
			qnty = parseFloat($(this).val())
			available = parseFloat($(this).attr('data-stock-available'))
			pro_input_qty = pro_input_qty + qnty
			pro_available_qty = pro_available_qty + available
			return
		mismatch = pro_available_qty - pro_input_qty
		$(".stock-mismatch-#{pro_id}").html(mismatch)
		if mismatch > 0
			$("#remarks_"+pro_id).prop('required', true)
		else
			$("#remarks_"+pro_id).prop('required', false)
		return

	########### Function to send purchase order ###########
	$(document).on "click", ".print_email",->
		htmlToPrint =""
		divToPrint = document.getElementById('email_printarea')
		htmlToPrint += divToPrint.innerHTML
		newWin = window.open('')
		newWin.document.write htmlToPrint
		newWin.print()
		newWin.close()

	$(document).on "click", ".send_now_order",->
		po_id = $(this).attr('id')
		console.log("called")
		po_button = $(this)
		request = undefined
		request = $.ajax(url: "/purchase_orders/send_purchase_order/?id="+po_id)
		request.done (data, textStatus, jqXHR) ->
			if $("#po_send_#{po_id}").hasClass('green')
				$("#po_send_#{po_id}").removeClass('green').addClass('blue')
			$("#po_send_#{po_id}").attr('data-po-sent','yes') 
			console.log data
			po_details_request = $.ajax(url: "/purchase_orders/get_send_purchase_order_details/?id="+po_id)
			po_details_request.done (data, textStatus, jqXHR) ->
				console.log('response data')
				console.log(data)
				if data.mail_conf == "enabled"
					po_result = JST["templates/purchase_orders/po_mail_details"](data)
					$('#showPurchaseOrderMailModal').html po_result
					$('#showPurchaseOrderMailModal').modal('show')
				return
			po_details_request.error (jqXHR, textStatus, errorThrown) ->
				Materialize.toast("There was a problem while fetch purchase order mail details", 5000)
				return
			Materialize.toast("You have successfully sent this purchase order (PO ID: #{po_id})", 5000)
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			Materialize.toast("There was a problem while sending this purchase order", 5000)
			return
		return

	########### Function to send requisition ###########
	$(document).on "click", ".send_now_inventory_req",->
		requisition_id = $(this).attr('id')
		request = undefined
		request = $.ajax(url: "/store_requisitions/send_requisition/?id="+requisition_id)
		request.done (data, textStatus, jqXHR) ->
			#console.log data
			Materialize.toast("You have successfully sent this requisition (REQ ID: #{requisition_id})", 5000)
			# $(".flash-success-notice-container").show()
			# $(".flash-success-notice").html "You have successfully sent this requisition."
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			Materialize.toast("There was a problem while sending this requisition", 5000)
			# $(".flash-error-notice-container").show()
			# $(".flash-error-notice").html "There was a problem while sending this requisition."
			return
		return
	############# Callback function for requisition details in Modal ###################
	$(document).on "click", ".view-recevd-req-details",->
		id = $(this).attr('data-req-log-id')
		current_store_id = $(this).attr('data-store-id')
		request = undefined
		request = $.ajax(url: "/api/v2/store_requisitions/get_requistion_deta?log_id="+id+"&store_id="+current_store_id)
		request.done (data, textStatus, jqXHR) ->
			console.log data
			data = data
			data.current_store = current_store_id
			result = undefined
			result = JST["templates/stores/requisition_details"](data)
			$("#showRequisitionModalDetails").html result
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			alert "AJAX Error:" + textStatus
			return
		return

	$(document).on "change keyup", ".input-product-stcok", ->
		input_quantity = $(this).val()
		current_stock = $(this).data("current-stock")
		if input_quantity > current_stock
			$(this).addClass('error-rais')
			$(this).val ''
		else
			$(this).removeClass('error-rais')  
		return   
	############# Callback function for purchase order details in Modal ###############
	$(document).on "click", ".view-po-details", (event) ->
		if $(this).attr('data-po-sent') == 'yes'
			if !window.confirm('Are you sure to send same po again?')
				$('#showPurchaseModal').modal('hide');
				return
		po_id = $(this).attr('data-po-id')
		store_id = $(this).attr('data-store-id')
		vendor_name = $(this).data("vendor-name")
		title_string = "Purchase order (Send to : #{vendor_name})"
		$(".purchse-title").html ''
		$(".purchse-title").html(title_string)
		request = $.ajax
								url: "/stores/"+store_id+"/purchase_orders/"+po_id+".json"
								method: 'GET'
								dataType: "json"
		request.done (data, textStatus, jqXHR) ->
			data.package_obj = data
			console.log data 
			result = JST["templates/stores/po_details"](data)
			$("#showPurchaseOModalDetails").html result
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			alert "AJAX Error:" + textStatus
			return
		return

	$(document).on "keyup change click", ".stock-report-input",->
		category = $(".store-product-category").val()
		from_date = $(".stock-from-date").val()
		to_date = $(".stock-to-date").val()
		product_name = $(".store-product-name").val()
		store_id = $(".export-stock-report").attr("date-store-id")
		href = "/stores/#{store_id}/reports.csv?category=#{category}&from_date=#{from_date}&to_date=#{to_date}&product_filter=#{product_name}"
		$(".export-stock-report").prop('href', href);
		# alert href

	$(document).on "click", ".view-boxing-details",->
		id = $(this).attr('data-boxing-id')
		current_store_id = $(this).attr('data-store-id')
		request = undefined
		request = $.ajax(url: "/api/v2/boxings/#{id}.json")
		request.done (data, textStatus, jqXHR) ->
			console.log data
			data = data
			data.current_store = current_store_id
			result = undefined
			result = JST["templates/boxings/boxing_details"](data)
			$("#showBoxingModalDetails").html result
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			alert "AJAX Error:" + textStatus
			return
		return


	# $(document).on "click", ".print-barcodde",->
	# 	sku = $(this).data('sku')
	# 	name = encodeURI($(this).data('name'))
	# 	site_name = $(this).data('site')
	# 	count = $(this).data('count')
	# 	mrp = if $(this).data('mrp') == null then "000000/-" else $(this).data('mrp')
	# 	wt = if $(this).data('wt') == null then "0.0" else $(this).data('wt')
	# 	mc = if $(this).data('mc') == null then "000000/-" else $(this).data('mc')
	# 	wst = if $(this).data('wastage') == null then "0.0" else $(this).data('wastage')
	# 	model_number = if $(this).data('model-number') == null then "-" else $(this).data('model-number')
	# 	size = if $(this).data('size') == null then "-" else $(this).data('size')
	# 	color_name = if $(this).data('color-name') == null then "-" else $(this).data('color-name')
		
	# 	$('.bar-mrp').html "MRP : " + mrp
	# 	$('.bar-title').html decodeURI(name)
	# 	$('.bar-weight').html " G : " + wt
	# 	$('.bar-making-cost').html "MC : " + mc + "&nbsp&nbsp&nbsp W : " + wst
	# 	$('.bar-sku').html sku
	# 	$('#radio_by_weight').html("<input class='type_radio' id='type_by_weight' name='type' value='by_weight' type='radio' data-f-l1="+site_name+" data-f-l2="+name+" data-f-l3="+sku+" data-b-l1='G : "+wt+"' data-count="+count+" data-b-l2='MC : "+mc+"      W : "+wst+"'><label for='type_by_weight'></label>")
	# 	$('#radio_by_mrp').html("<input class='type_radio' id='type_by_mrp' name='type' value='by_mrp' type='radio' data-f-l1="+site_name+" data-f-l2='MRP : "+mrp+"' data-f-l3="+sku+" data-b-l1='MRP : "+mrp+"' data-b-l2='' data-count="+count+"><label for='type_by_mrp'></label>")
	# 	$('#radio_by_catalog').html("<input class='type_radio' id='type_by_catalog' name='type' value='by_catalog' type='radio' data-f-l1="+site_name+" data-f-l2='MRP : "+mrp+"' data-f-l3="+sku+" data-b-l1='MRP : "+mrp+"' data-b-l2='' data-count="+count+" data-m-l1="+model_number+" data-s-l1="+size+" data-c-l1="+color_name+" checked='checked'><label for='type_by_catalog'></label>")
	# 	$('#print_modal').modal("show")

	# $(document).on "click", ".print-barcode",->
	# 	if $('input:radio[name=type]:checked').length == 0
	# 		Materialize.toast("Please select a pattarn first.", 5000)
	# 	else
	# 		f_l1 = $('input:radio[name=type]:checked').data('f-l1')
	# 		f_l2 = $('input:radio[name=type]:checked').data('f-l2')
	# 		f_l3 = $('input:radio[name=type]:checked').data('f-l3')
	# 		f_l4 = $('input:radio[name=type]:checked').data('f-l4')
	# 		b_l1 = $('input:radio[name=type]:checked').data('b-l1')
	# 		b_l2 = $('input:radio[name=type]:checked').data('b-l2')
	# 		count = $('input:radio[name=type]:checked').data('count')
	# 		m_l1 = $('input:radio[name=type]:checked').data('m-l1')
	# 		s_l1 = $('input:radio[name=type]:checked').data('s-l1')
	# 		c_l1 = $('input:radio[name=type]:checked').data('c-l1')
	# 		print_url = "http://localhost:3000/?f-l1=#{f_l1}&f-l2=#{f_l2}&f-l3=#{f_l3}&f-l4=#{f_l3}&b-l1=#{b_l1}&b-l2=#{b_l2}&b-l3=#{f_l3}&b-l4=#{f_l3}&m-l1=#{m_l1}&s-l1=#{s_l1}&c-l1=#{c_l1}&count=#{Math.trunc(count)}"
	# 		$.ajax
	# 			type: 'GET'
	# 			dataType: 'text'
	# 			url: print_url
	# 			success: (responseData, textStatus, jqXHR) ->
	# 				#alert responseData
	# 				$('#print_modal').modal("hide")
	# 			error: (responseData, textStatus, errorThrown) ->
	# 				alert "Printer server is offline"
	# 				console.log print_url
	# 		return

	$(document).on "click", ".print-barcodde",->
	  sku = $(this).data('sku')
	  name = encodeURI($(this).data('name'))
	  site_name = encodeURI($(this).data('site'))
	  count = $(this).data('count')
	  mrp = if $(this).data('mrp') == null then "000000/-" else $(this).data('mrp')
	  wt = if $(this).data('wt') == null then "0.0" else $(this).data('wt')
	  mc = if $(this).data('mc') == null then "000000/-" else $(this).data('mc')
	  wst = if $(this).data('wastage') == null then "0.0" else $(this).data('wastage')
	  model_number = encodeURI($(this).data('model-number'))
	  size = if $(this).data('size') == null then "-" else $(this).data('size')
	  size = encodeURI(size)
	  color_name = if $(this).data('color-name') == null then "-" else $(this).data('color-name')
	  created_at = $(this).data('created-at')
	  mfg_date = $(this).data('mfg-date')
	  # batch_no = if $(this).data('batch-no') == null then "-" else $(this).data('batch-no')
	  batch_no = $(this).data('batch-no')
	  itemname = encodeURI($(this).data('itemname'))
	  rpo = $(this).data('rpo')
	  sale_price = $(this).data('sale-price')
	  currency = $(this).data('currency')
	  exp_date = $(this).data('exp-date')
	  quantity = encodeURI($(this).data('quantity'))

	  $("#print_count").val(parseInt(count))
	  
	  $('.bar-mrp').html "MRP : " + mrp
	  $('.bar-title').html decodeURI(name)
	  $('.bar-weight').html " G : " + wt
	  $('.bar-making-cost').html "MC : " + mc + "&nbsp&nbsp&nbsp W : " + wst
	  $('.bar-sku').html sku
	  $('#radio_by_weight').html("<input class='type_radio' id='type_by_weight' name='type' value='by_weight' type='radio' data-f-l1="+site_name+" data-f-l2="+name+" data-f-l3="+sku+" data-b-l1='G : "+wt+"' data-count="+count+" data-b-l2='MC : "+mc+"      W : "+wst+"'><label for='type_by_weight'></label>")
	  $('#radio_by_mrp').html("<input class='type_radio' id='type_by_mrp' name='type' value='by_mrp' type='radio' data-f-l1="+site_name+" data-f-l2='MRP : "+mrp+"' data-f-l3="+sku+" data-b-l1='MRP : "+mrp+"' data-b-l2='' data-count="+count+"><label for='type_by_mrp'></label>")
	  $('#radio_by_catalog').html("<input class='type_radio' id='type_by_catalog' name='type' value='by_catalog' type='radio' data-f-l1="+site_name+" data-f-l2='"+mrp+"' data-f-l3="+sku+" data-b-l1='"+mrp+"' data-b-l2='-' data-count="+count+" data-m-l1="+model_number+" data-s-l1="+size+" data-c-l1="+color_name+" data-created-at="+created_at+" data-mfg-date="+mfg_date+" data-batch-no="+batch_no+" data-itemname=#{itemname} data-rpo=#{rpo} data-sale-price=#{sale_price} data-currency=#{currency} data-exp-date=#{exp_date} data-quantity=#{quantity} checked='checked'><label for='type_by_catalog'></label>")
	  $('#print_modal').modal("show")

	$(document).on "click", ".print-barcode",->
	  if $('input:radio[name=type]:checked').length == 0
	    Materialize.toast("Please select a pattarn first.", 5000)
	  else
	    f_l1 = decodeURI($('input:radio[name=type]:checked').data('f-l1'))
	    f_l2 = $('input:radio[name=type]:checked').data('f-l2')
	    f_l3 = $('input:radio[name=type]:checked').data('f-l3')
	    f_l4 = $('input:radio[name=type]:checked').data('f-l4')
	    b_l1 = $('input:radio[name=type]:checked').data('b-l1')
	    b_l2 = $('input:radio[name=type]:checked').data('b-l2')
	    itemname = decodeURI($('input:radio[name=type]:checked').data('itemname'))
	    # count = $('input:radio[name=type]:checked').data('count')
	    count = $("#print_count").val()
	    if count.length == 0
	      count = 1
	    m_l1 = decodeURI($('input:radio[name=type]:checked').data('m-l1'))
	    s_l1 = decodeURI($('input:radio[name=type]:checked').data('s-l1'))
	    c_l1 = $('input:radio[name=type]:checked').data('c-l1')
	    d_l1 = $('input:radio[name=type]:checked').data('created-at')
	    mfg_d1 = $('input:radio[name=type]:checked').data('mfg-date')
	    batch_no = $('input:radio[name=type]:checked').data('batch-no')
	    sale_price = $('input:radio[name=type]:checked').data('sale-price')
	    currency = $('input:radio[name=type]:checked').data('currency')
	    exp_date = $('input:radio[name=type]:checked').data('exp-date')
	    qty = decodeURI($('input:radio[name=type]:checked').data('quantity'))
	    
	    print_url = "http://localhost:3000/?f-l1=#{f_l1}&f-l2=#{f_l2}&f-l3=#{f_l3}&f-l4=#{f_l3}&b-l1=#{b_l1}&b-l2=#{b_l2}&b-l3=#{f_l3}&b-l4=#{f_l3}&m-l1=#{m_l1}&s-l1=#{s_l1}&c-l1=#{c_l1}&d-l1=#{d_l1}&mfg=#{mfg_d1}&batchno=#{batch_no}&count=#{Math.trunc(count)}&production_itemname=#{itemname}&sale_price=#{sale_price}&currency=#{currency}&exp_date=#{exp_date}&quantity=#{qty}"
	    rpo = $('input:radio[name=type]:checked').data('rpo')
	    # alert print_url
	    $.ajax
	      type: 'GET'
	      dataType: 'text'
	      url: print_url
	      success: (responseData, textStatus, jqXHR) ->
	        # alert responseData
	        $('#print_modal').modal("hide")
	        $("#print_btn_#{rpo}").addClass('green')
	        $.ajax
	          type: 'PUT'
	          data:
	            stock_id: rpo
	          url: '/stocks/barcode_print_update'
	      error: (responseData, textStatus, errorThrown) ->
	        alert "Printer server is offline"
	        console.log print_url
	    return



	rack_id=""
	$(document).on "click", ".addbin",->
		rack_id = $(this).data("rack-id")
	$(document).on "click", "#addnewbin",->
		if($("#BinName").val() && $("#BinHeight").val() && $("#BinWidth").val())
			$.ajax "/store_racks/"+rack_id+"/bins.json", 
				method: 'POST'
				data: { bin:{name: $("#BinName").val(), height:$("#BinHeight").val(),width:$("#BinWidth").val()}}
				dataType: 'json'
				success: (data, textStatus, jqXHR) ->
					$('#AddBinsModal').modal('hide')
					Materialize.toast("Bin created successfully")
					return
				error: (jqXHR, textStatus, errorThrown) ->
					alert "AJAX Error: #{textStatus}"
					return
		else
			alert "please fill all the fields"
		return

	$(document).on "click", ".warehouse-rack", ->
		rack_id = $(this).data("rack-id")
		$(".rack-uid").text("#"+$(this).data("rack-uid"))
		$.ajax "/warehouse_meta/racks",
			method: 'GET',
			data: {id:rack_id},
			dataType:"json",
			success: (data,textStatus,jqXHR)->
				htmlStr = "<div class='grid-wrapper' style='width: 250px !important;grid-gap:9px !important;'>"
				for i in[0..data.data.length-1]
					if data.data[i]["status"] == "available"
						htmlStr+= "<div class='grid-box-available' style='width: 230px !important; height:50px !important'>#{data.data[i]['bin_unique_id']}</div>"
					if data.data[i]["status"] == "allocated"
						htmlStr+= "<div class='grid-box-allocated' style='width: 230px !important;height:50px !important'>#{data.data[i]['bin_unique_id']}</div>"
					if data.data[i]["status"] == "damaged"
						htmlStr+= "<div class='grid-box-damaged' style='width: 230px !important;height:50px !important'>#{data.data[i]['bin_unique_id']}</div>"
				htmlStr+="</div>"
				$("#ModalRack").html(htmlStr)	
				return
			error: (jqXHR, textStatus, errorThrown) ->
				console.log("error")
				return
		$("#RackModal").modal()

	$(document).on "change", "#store_user_role", ->
		role_id = $(this).val()
		request = $.ajax(
			type: 'GET'
			url: "/api/v2/users/get_users_by_role"
			data:
				role_id: role_id
		)
		request.done (data, textStatus, jqXHR) ->
			console.log data
			data.users = data
			result = JST["templates/users/get_users_by_role"](data)
			console.log result
			$("#store_user_id").html result
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			console.log textStatus
			Materialize.toast("Something went wrong.", 5000)
			return
		return
	$(document).on "change",".reason_select", ->
		meta_id = $(this).data("meta-id")
		remark = $(this).find('option:selected').text()
		$("#remark_#{meta_id}").val(remark)
		return

	$(document).on "click",".cancelled-po-edit", ->
		Materialize.toast("PO cancelled already, can not be edited.", 5000, "red")
		return

	$(document).on "click",".cancelled-po-send", ->
		Materialize.toast("PO cancelled already, can not be sent.", 5000, "red")
		return

	$(document).on "click","#total_po_cancel", ->
		return false if !window.confirm('Are you sure to cancel?')
		return

	$(document).on "click",".cancel_item_in_po", ->
		po_id = $(this).data('po-id')
		meta_id = $(this).data('meta-id')
		product_name = $(this).data('product-name')
		product_id = $(this).data('product-id')
		return false if !window.confirm("Are you sure to cancel #{product_name}?")
		if typeof meta_id == 'undefined'
			$(".new_meta_product_#{product_id}").remove()
			Materialize.toast("Item: #{product_name} removed successfully.", 5000, "green")
			return false
		request = $.ajax(
			type: 'POST'
			url: "/purchase_orders/cancel_po_item"
			data:
				meta_id: meta_id
				po_id: po_id
		)
		request.done (data, textStatus, jqXHR) ->
			console.log data
			$("#po_meta#{meta_id}").remove()
			Materialize.toast("Item: #{product_name} removed successfully.", 5000, "green")
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			console.log textStatus
			Materialize.toast("Something went wrong.", 5000)
			return
		return