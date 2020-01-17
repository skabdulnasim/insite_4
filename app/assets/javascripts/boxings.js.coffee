# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->

	components_in_package = 0
	remaining_components_to_insert = 0

	$("#take-box-btn").prop("disabled",true)
	$("#confirm-boxing-btn").css("pointer-events","none")

	$("#package-selection-div,#boxing-div").hide()

	$(document).on "change", "#boxing_source",->
		boxing_source = $(this).val()
		if boxing_source == 'Package'
			$("#package-selection-div,#boxing-div").show()
		return

	$(document).on 'click', '#confirm-boxing-btn', (event)->
		if parseInt($(".components_no").text()) > 0
			Materialize.toast("Some products are missing for the packaging", 2000, 'red')
			return false

	$(document).on 'click', '#create-boxing-btn', (event)->
		boxing_name = $('#create-boxing').val()
		is_created = $(this).attr('data-is-created')
		boxing_source_type = $("#boxing_source").val()
		boxing_source_id = $("#package").val()
		store_id = $("#store_id").val()
		if boxing_source_type.length == 0 || boxing_source_id.length == 0
			Materialize.toast("Please select a package", 2000, 'red')
			return false
		if boxing_name.length == 0
			Materialize.toast("Please enter a title for the boxing", 2000, 'red')
			return false
		if is_created == 'false'
			request = $.ajax(
				type: 'POST'
				url: '/api/v2/boxings'
				dataType: "json"
				data:
					boxing:
						name: boxing_name
						boxing_source_type: boxing_source_type
						boxing_source_id: boxing_source_id
						store_id: store_id
			)
		else
			boxing_id = $("#boxing-id").val()
			request = $.ajax(
				type: 'PUT'
				url: "/api/v2/boxings/#{boxing_id}.json"
				dataType: "json"
				data:
					boxing:
						name: boxing_name
						boxing_source_type: boxing_source_type
						boxing_source_id: boxing_source_id
						store_id: store_id
			)
		request.done (data, textStatus, jqXHR) ->
			console.log data
			Materialize.toast("Boxing saved successfully: #{data.data.name}", 2000, 'green')
			$("#boxing-id").val data.data.id
			$('#create-boxing-btn').attr("data-is-created",'true')
			$("#take-box-btn").attr("disabled",false)
			$("#take-box-btn").removeClass('bg-gray')
			$("#take-box-btn").addClass('blue')
			$("#confirm-boxing-btn").css("pointer-events","auto")

			$("#boxing_source").attr("disabled",true)
			$("#package").attr("disabled",true)
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			alert "Error"
			return
		return

	$(document).on "change", "#package",->
		package_id = $(this).val()
		request = $.ajax(
			type: 'GET'
			url: "/api/v2/packages/package_details"
			dataType: "json"
			data:
				package_id: package_id
		)
		request.done (data, textStatus, jqXHR) ->
			console.log data
			components_in_package = data.data.total_product_count
			remaining_components_to_insert = data.data.total_product_count
			contentStr = "<div id='package-component-#{data.data.id}'><label>Number of components in #{data.data.name} : </label><span class='margin-l-15 badge padding-l-r-10 teal text_white'>#{components_in_package}</span></div>"
			contentStr += "<div id='package-remaining-component-#{data.data.id}'><label>Number of remaining components to insert: </label><span class='margin-l-15 badge padding-l-r-10 teal text_white components_no'>#{components_in_package}</span></div>"
			$("#package_components").html contentStr
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			alert "Error"
			return

		return	

	$('#create-boxing').keypress (e) ->
		if e.which == 13
			$('#create-boxing-btn').click()
		return

	$('#search-box').keypress (e) ->
		if e.which == 13
			$('#search-box-btn').click()
		return

	$(document).on 'keypress', '.search-box-item', (e)->
		if e.which == 13
			$(this).parent().parent().children('.insert-product-div').children('.insert-product').click()
		return

	$(document).on 'click', '#search-box-btn', (event)->
		box_barcode = $("#search-box").val()
		store_id = $("#store_id").val()
		if box_barcode.length == 0
			Materialize.toast("Please enter a barcode to select a box", 2000, 'red')
			return false
		request = $.ajax(
			type: 'POST'
			url: "/api/v2/boxings/search_by_barcode"
			dataType: "json"
			data:
				sku: box_barcode
				store_id: store_id
		)
		request.done (data, textStatus, jqXHR) ->
			console.log data
			if data.data.product_found == 'yes'
				contentStr = "<label class='col-lg-3' control-label'>Box Name</label>"
				contentStr += "<div class='col-lg-6'>#{data.data.product_name}</div>"
				contentStr += "<div class='col-lg-3'>"
				contentStr += "<input id='box-product-id' type='hidden' value='#{data.data.product_id}'>"
				contentStr += "<input id='box-stock-id' type='hidden' value='#{data.data.stock_id}'>"
				contentStr += "<input id='box-sku' type='hidden' value='#{data.data.sku}'>"
				contentStr += "</div>"
				$("#selected-box").html contentStr
				$('#create-box-btn').click()
			else
        Materialize.toast("No product found with #{box_barcode}", '4000', 'red')
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			alert "Error"
			return
		return

	$(document).on 'click', '#create-box-btn', (event)->
		boxing_id = $("#boxing-id").val()
		product_id = $("#box-product-id").val()
		stock_id = $("#box-stock-id").val()
		sku = $("#box-sku").val()

		request = $.ajax(
			type: 'POST'
			url: "/api/v2/boxings/create_box"
			dataType: "json"
			data:
				box:
					boxing_id: boxing_id
					product_id: product_id
					stock_id: stock_id
					sku: sku
		)
		request.done (data, textStatus, jqXHR) ->
			console.log data

			contentStr = "<div class='margin-t-15'>"
			contentStr += "<div class='col-lg-4'>"
			contentStr += "<div style='margin-left: 37%;'><label>Box</label></div>"
			contentStr += "<div class='card margin-t-15 box-card-div' style='width:250px;min-height:200px'>"
			contentStr += "<div class='padding-10 text_white box-name txt-align-center' style='background:green;'>#{data.data.package_name} #{data.data.product_name} <span class='right badge white text-black items_no_in_box items_no_in_box_#{data.data.id}'>0</span></div>"
			contentStr += "<div class='items-inside-box'></div>"
			contentStr += "</div>"
			contentStr += "<div class='margin-t-5 search-box-item-div'>"
			contentStr += "<input autocomplete='off' class='search-box-item blue-input z-depth-2 form-control' style='width: 84%;' placeholder='Search by sku...' type='text'/>"
			contentStr += "</div>"
			contentStr += "<div class='insert-product-div'>"
			contentStr += "<a class='m-btn blue waves-effect waves-light insert-product margin-t-15' id='insert-product-#{data.data.id}' data-box-id='#{data.data.id}' style='width: 84%;'>Insert product</a>"
			contentStr += "</div>"
			contentStr += "</div>"

			$("#selected-boxes").append contentStr
			Materialize.toast("Box added successfully: #{data.data.product_name}", 4000, 'green')
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			alert "Error"
			return

		return

	$(document).on 'click', '.insert-product', (event)->
		item_barcode = $(this).parent().parent().children('.search-box-item-div').children('.search-box-item').val()
		box_id = $(this).data('box-id')
		store_id = $("#store_id").val()
		package_id = $("#package").val()
		current_insert_item_btn = $(this)
		if item_barcode.length == 0
			Materialize.toast("Please enter a barcode to select a box item", 2000, 'red')
			return false
		request = $.ajax(
			type: 'POST'
			url: "/api/v2/boxings/search_by_barcode"
			dataType: "json"
			data:
				sku: item_barcode
				store_id: store_id
				package_id: package_id
		)
		request.done (data, textStatus, jqXHR) ->
			console.log data
			sku = data.data.sku
			if data.data.product_found == 'yes'
				if data.data.stock_checked == 'yes'
					# if !window.confirm("Are you sure to insert #{data.data.product_name} ?")
	    			# return false
					requestBoxItem = $.ajax(
						type: 'POST'
						url: "/api/v2/boxings/create_box_item"
						dataType: "json"
						data:
							package_id: package_id
							box_item:
								box_id: box_id
								product_id: data.data.product_id
								stock_id: data.data.stock_id
								sku: data.data.sku
								qty: data.data.qty_in_pckg
					)
					requestBoxItem.done (boxItemData, textStatus, jqXHR) ->
						console.log data
						if boxItemData.data.product_found_in_package == "yes"
							if remaining_components_to_insert > 0
								remaining_components_to_insert = remaining_components_to_insert - 1
							
								contentStr = "<div class='box-item-div'>"
								contentStr += "<div class='padding-t-b-5 padding-l-r-10 txt-align-center text_white box-item-name' style='background:#79c;border-top: 1px black solid;'>#{boxItemData.data.product_name}"
								contentStr += "<span title='Unbox product' class='text-red white badge right unbox-item' data-box-id=#{boxItemData.data.box_id} data-box-item-id=#{boxItemData.data.id}><i class='fa fa-close'></i></span>"
								contentStr += "<span title='Qty in package' class='text-green white badge right' data-box-id=#{boxItemData.data.box_id} data-box-item-id=#{boxItemData.data.id}>#{boxItemData.data.qty} #{boxItemData.data.product_basic_unit}</span>"
								contentStr += "</div>"
								contentStr += "</div>"
								current_insert_item_btn.parent().parent().children('.box-card-div').children('.items-inside-box').append contentStr
								Materialize.toast("#{data.data.product_name} inserted in the box", 4000, 'green')
								current_insert_item_btn.parent().parent().children('.search-box-item-div').children('.search-box-item').val("")
								
								$("#package-remaining-component-#{package_id}").children('.components_no').html remaining_components_to_insert
								items_no = current_insert_item_btn.parent().parent().children('.box-card-div').children('.box-name').children('.items_no_in_box').text()
								items_no = parseInt(items_no) + 1
								current_insert_item_btn.parent().parent().children('.box-card-div').children('.box-name').children('.items_no_in_box').html items_no
							else
								Materialize.toast("All products have been inserted in the package.", 4000, "red")
						else if boxItemData.data.product_found_in_package == "no"
							Materialize.toast("Product not found in the package", 4000, 'red')
						return
					requestBoxItem.error (jqXHR, textStatus, errorThrown) ->
						alert "Error"
						return
				else
					Materialize.toast("Insufficient stock", '2000', 'red')
			else
        Materialize.toast("No product found with #{item_barcode}", '2000', 'red')
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			alert "Error"
			return
		return

	$(document).on 'click', '.unbox-item', (event)->
		box_id = $(this).data('box-id')
		box_item_id = $(this).data('box-item-id')
		package_id = $("#package").val()
		unbox_btn = $(this)
		request = $.ajax(
			type: 'POST'
			url: "/api/v2/boxings/remove_box_item"
			dataType: "json"
			data:
				box_item_id: box_item_id
		)
		request.done (data, textStatus, jqXHR) ->
			unbox_btn.parent().parent('.box-item-div').remove()
			remaining_components_to_insert = remaining_components_to_insert + 1
			$("#package-remaining-component-#{package_id}").children('.components_no').html remaining_components_to_insert
			items_no_in_box = parseInt($(".items_no_in_box_#{box_id}").text())
			items_no_in_box = items_no_in_box - 1
			$(".items_no_in_box_#{box_id}").html items_no_in_box
			Materialize.toast("Item removed from box", 2000, 'green')
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			alert "Error"
			return
		return





