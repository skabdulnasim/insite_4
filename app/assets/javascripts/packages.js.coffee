# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
	$('#wizard_horizontal').steps
		headerTag: 'h3'
		bodyTag: 'section'
		enableAllSteps: true
		transitionEffect: 'fade'
		stepsOrientation: 'horizontal'
		showFinishButtonAlways: true
		onStepChanging: (event, currentIndex, newIndex) ->
			true  
		onFinished: (event, currentIndex) ->
			# form = $('.sale_rule_form_wizard')
			# form.submit()
			return 

	$(".button_finish").children('a').click ->
		window.location.href = '/packages'

	$('#customer-mobile-no').keypress (e) ->
		if e.which == 13
			$('#customer-search-btn').click()
		return
	
	$(document).on 'click', '#customer-search-btn', (event)->
		mobile_no = $('#customer-mobile-no').val()
		if mobile_no.length == 0
			Materialize.toast("Please enter a phone number", 2000, 'red')
			return false
		request = $.ajax(
			type: 'POST'
			# url: '/packages/find_customer'
			url: '/api/v2/customers/find_by_login'
			dataType: "json"
			data:
				login: mobile_no
		)
		request.done (data, textStatus, jqXHR) ->
			console.log data
			data.response = data
			data.entered_mobile_no = mobile_no
			result = JST["templates/packages/customer"](data)
			console.log result
			$("#customer-form").html result
			$("#customer-id").val data.data.id
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			alert "Error"
			return
		return

	#register new customer
	$(document).on "click", "#register-customer",-> 
		request = $.ajax(
			type: 'POST'
			url: "/api/v2/customers"
			dataType: "json"
			data:
				customer_email:   $("#email").val()
				contact_no:       $("#contact_no").val()
				gstin:            $("#gstin").val()
				firstname:        $("#address_receiver_first_name").val()
				lastname:         $("#address_receiver_last_name").val()
		)
		request.done (data, textStatus, jqXHR) ->
			console.log data
			findRequest = $.ajax(
				type: 'POST'
				url: '/api/v2/customers/find_by_login'
				dataType: "json"
				data:
					login: data.data.mobile_no
			)
			findRequest.done (data, textStatus, jqXHR) ->
				console.log data
				data.response = data
				data.entered_mobile_no = data.data.mobile_no
				result = JST["templates/packages/customer"](data)
				console.log result
				$("#customer-form").html result
				$("#customer-id").val data.data.id
				return
			findRequest.error (jqXHR, textStatus, errorThrown) ->
				alert "Error"
				return 
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			console.log textStatus
			alert "error"
			return    
		return  

	$(document).on "click", "#add-new-address",->
		# $(window).off('scroll')
		result = JST["templates/packages/address"]
		console.log result
		# $("#address-fields").fadeOut 200
		$("#address-fields").html result
		# $("#address-fields").fadeIn 2000
		# $("#address_pincode").focus()
		return

	$(document).on "click", "#save-address-btn",->
		request = $.ajax(
			type: 'POST'
			url: "/api/v2/customers/add_address"
			dataType: "json"
			data:
				email:            $("#user-email").val()
				device_id:        "YOTTO05"
				customer_id:      $("#customer-id").val()
				first_name:       $("#address_first_name").val()
				last_name:        $("#address_last_name").val()
				city:             $("#address_city").val()
				delivery_address: $("#delivery_address").val()
				landmark:         $("#address_landmark").val()
				pincode:          $("#address_pincode").val()
				state:            $("#address_state").val()
				contact_no:       $("#address_contact_no").val()
		)
		request.done (data, textStatus, jqXHR) ->
			console.log data
			contentStr = "<div class='card card-panel padding-10'>"
			contentStr += "<input class='with-gap' name='customer_address' type='radio' id='customer_address_#{data.data.id}' value='#{data.data.id}' data-address-firstname='#{data.data.receiver_first_name}' data-address-lastname='#{data.data.receiver_last_name}' data-delivery-address='#{data.data.delivery_address}' data-address-landmark='#{data.data.landmark}' data-address-city='#{data.data.city}' data-address-pincode='#{data.data.pincode}' data-address-state='#{data.data.state}' data-address-contact='#{data.data.contact_no}'/>"
			contentStr += "<label for='customer_address_#{data.data.id}'>#{data.data.receiver_first_name} #{data.data.receiver_last_name}</label><br>"
			contentStr += "<span>"
			contentStr += "#{data.data.delivery_address},"
			contentStr += "#{data.data.landmark},"
			contentStr += "#{data.data.city} - "
			contentStr += "#{data.data.pincode},"
			contentStr += "#{data.data.state}<br>"
			contentStr += "Contact:#{data.data.contact_no}" 
			contentStr += "</span>"
			contentStr += "</div>"
			$("#customer-addresses").append contentStr
			$("#address-fields").html ''
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			console.log textStatus
			alert "error"
			return    
		return

	$(document).on "click", "input[name='customer_address']",->
		firstname = $(this).data('address-firstname')
		lastname = $(this).data('address-lastname')
		delivery_address = $(this).data('delivery-address')
		$("#package-customer-name").html "#{firstname} #{lastname}"
		$("#package-customer-address").html "#{delivery_address}"
		return

	$(document).on "click", ".add-sub-units",->
		package_unit_name = $(this).parent().children('.package-unit-name').val()
		package_id = $("#package-id").val()
		parent_unit = $(this).parent().children('.package-unit-name').data('parent-unit-id')
		add_sub_unit_btn = $(this)
		is_created = $(this).attr("data-is-created")
		if is_created == 'false'
			request = $.ajax(
				type: 'POST'
				url: '/api/v2/packages/create_package_unit'
				dataType: "json"
				data:
					package_unit_name:  package_unit_name
					parent_unit:        parent_unit
					package_id:         package_id
			)
		else
			package_unit_id = $(this).attr('data-package-unit-id')
			request = $.ajax(
				type: 'POST'
				url: "/api/v2/packages/edit_package_unit"
				dataType: "json"
				data:
					package_unit_id:    package_unit_id
					package_unit_name:  package_unit_name
			)
		request.done (data, textStatus, jqXHR) ->
			console.log data
			add_sub_unit_btn.attr("data-is-created",'true')
			add_sub_unit_btn.attr("data-package-unit-id","#{data.data.id}")
			add_sub_unit_btn.parent().children('.remove-package-unit').attr("data-package-unit-id","#{data.data.id}")
			add_sub_unit_btn.parent().children('.add_unit_bom').children('a').removeClass 'green'
			add_sub_unit_btn.parent().children('.add_unit_bom').children('a').css('background','#999')
			add_sub_unit_btn.parent().children('.add_unit_bom').css("pointer-events","none")

			contentStr = "<div class='package-units padding-l-35'>"
			contentStr += "<div class='input-group'>"
			contentStr += "<input autocomplete='off' data-parent-unit-id=#{data.data.id} class='package-unit-name margin-t-10 blue-input z-depth-2 form-control float-r' placeholder='Enter unit name' type='text' name='package_unit_name'>"
			contentStr += "<span class='input-group-btn add-sub-units' data-is-created='false' style='visibility:hidden;'>"
			contentStr += "<a class='m-btn green m-btn-low-padding' style='margin-left:20px; margin-top: 8px;'>"
			contentStr += "<i class='mdi-content-add'></i>"
			contentStr += "</a>"
			contentStr += "</span>"
			contentStr += "<span class='input-group-btn add_unit_bom'>"
			contentStr += "<a class='m-btn green m-btn-low-padding right' style='margin-left:10px; margin-top: 8px; width: 36px;'>"
			contentStr += "<i class='fa fa-bold'></i>"
			contentStr += "</a>"
			contentStr += "</span>"
			contentStr += "<span class='input-group-btn remove-package-unit'>"
			contentStr += "<a class='m-btn red m-btn-low-padding right' style='margin-left:10px; margin-top: 8px; width: 36px;'>"
			contentStr += "<i class='mdi-action-highlight-remove'></i>"
			contentStr += "</a>"
			contentStr += "</span>"
			contentStr += "</div>"
			contentStr += "<div class='col-lg-12 add-product-form'></div>"
			contentStr += "</div>"
			add_sub_unit_btn.closest('.package-units').append(contentStr)
			# $(this).children('a').removeClass 'green'
			# $(this).children('a').addClass 'red'
			# $(this).css("pointer-events", "none")
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			alert "Error"
			return
		return

	$(document).on "click", ".remove-package-unit",->
		package_unit_id = $(this).attr('data-package-unit-id')
		remove_package_unit_btn = $(this)
		if package_unit_id != undefined
			request = $.ajax(
				type: 'POST'
				url: '/api/v2/packages/remove_package_unit'
				dataType: "json"
				data:
					package_unit_id:  package_unit_id
			)
			request.done (data, textStatus, jqXHR) ->
				remove_package_unit_btn.parent().parent('.package-units').remove()
				Materialize.toast("Unit removed", 2000, 'green')
				return
			request.error (jqXHR, textStatus, errorThrown) ->
				alert "Error"
				return
		else
			$(this).parent().parent('.package-units').remove()
			Materialize.toast("Unit removed", 2000, 'green')
		return

	# $(document).on "click", "#add_product",->
	#   request = $.ajax(
	#     type: 'GET'
	#     url: '/api/v2/packages/required_product_fields'
	#     dataType: "json"
	#   )
	#   request.done (data, textStatus, jqXHR) ->
	#     console.log data
	#     data.response = data
	#     result = JST["templates/packages/product"](data)
	#     # console.log result
	#     $("#product-form").html result
	#     return
	#   request.error (jqXHR, textStatus, errorThrown) ->
	#     alert "Error"
	#     return
	#   return

	$(document).on "click", ".add-products",->
		product_name = $(this).parent().parent().children('.outer_product_name').children('.product_name').val()
		product_category = $(this).parent().parent().children('.outer_product_category').children('.product_category').val()
		product_basic_unit = $(this).parent().parent().children('.outer_product_basic_unit').children('.product_basic_unit').val()
		product_quantity = $(this).parent().parent().children('.outer_product_quantity').children('.product_quantity').val()
		subunit_id = $(this).data('subunit-id')
		current_add_product_btn = $(this)
		current_add_product_btn_parent = current_add_product_btn.parent().parent()
		menu_card_id = $(this).parent().parent().children('.outer_menu_cards').children('.menu_cards').val()
		menu_category_id = $(this).parent().parent().children('.outer_menu_categories').children('.menu_categories').val()
		package_id = $("#package-id").val()

		packageComponentRequest = $.ajax(
			type: 'POST'
			url: '/api/v2/packages/add_package_component'
			dataType: "json"
			data:
				name:             product_name
				category_id:      product_category
				basic_unit_id:    product_basic_unit
		)
		packageComponentRequest.done (data, textStatus, jqXHR) ->
			package_component_id = data.data.id
			new_product_name = "#{package_id}-#{subunit_id}-#{package_component_id}"
			package_component_name = data.data.name
			request = $.ajax(
				type: 'POST'
				url: '/api/v2/packages/add_product'
				dataType: "json"
				data:
					name:                 new_product_name
					category_id:          product_category
					basic_unit_id:        product_basic_unit
					menu_card_id:         menu_card_id
					menu_category_id:     menu_category_id
					package_component_id: package_component_id
			)
			request.done (data, textStatus, jqXHR) ->
				console.log data
				product_id = data.data.id
				basic_unit = data.data.basic_unit
				# created_product_name = data.data.name
				dataRequest = $.ajax(
					type: 'POST'
					url: '/api/v2/packages/add_package_unit_product'
					dataType: "json"
					data:
						package_unit_id:      subunit_id
						product_id:           product_id
						quantity:             product_quantity
						production_status:    '0'
				)
				dataRequest.done (data, textStatus, jqXHR) ->
					Materialize.toast("Product added successfully", 2000, 'green')
					# current_add_product_btn.parent().parent().children('.outer_product_details').children('.inner_product_details').attr('disabled', true)
					# current_add_product_btn.parent().html ''
					# current_add_product_btn.parent().parent().html ''
					contentStr = "<div class='input-group margin-t-15 col-lg-12'>"
					contentStr += "<div class='input-group-addon'>#{package_component_name}</div>"
					contentStr += "<div class='input-group-addon'>#{product_quantity} #{basic_unit}</div>"
					contentStr += "<span class='input-group-btn open_product_bom' data-product-id=#{product_id}>"
					contentStr += "<a class='m-btn green m-btn-low-padding right' style='width: 36px;'>"
					contentStr += "<i class='fa fa-bold'></i>"
					contentStr += "</a>"
					contentStr += "</span>"
					contentStr += "<span class='input-group-btn remove-saved-product' data-product-id=#{product_id} data-package-unit-product-id=#{data.data.id}>"
					contentStr += "<a class='m-btn red m-btn-low-padding left margin-l-5' style='width: 36px;'>"
					contentStr += "<i class='mdi-action-highlight-remove'></i>"
					contentStr += "</a>"
					contentStr += "</span>"
					contentStr += "</div>"
					current_add_product_btn.parent().parent().html contentStr
					getproduct = $.ajax(
						type: 'GET'
						url: "/api/v2/products/#{product_id}.json"
						dataType: "json"
					)
					getproduct.done (data, textStatus, jqXHR) ->
						console.log data
						data.response = data
						result = JST["templates/packages/product_compositions"](data)
						console.log result
						current_add_product_btn_parent.append result
						return
					return
				return
			request.error (jqXHR, textStatus, errorThrown) ->
				alert "Error"
				return  
			return
		packageComponentRequest.error (jqXHR, textStatus, errorThrown) ->
			alert "Error"
			return
		return

	$(document).on "click", ".remove-products",->
		$(this).parent().parent().remove()
		Materialize.toast('Product removed', 2000, 'red')
		return

	$(document).on "click", ".remove-saved-product",->
		package_unit_product_id = $(this).attr('data-package-unit-product-id')
		remove_saved_product_btn = $(this)
		request = $.ajax(
			type: 'POST'
			url: '/api/v2/packages/remove_package_unit_product'
			dataType: "json"
			data:
				package_unit_product_id:  package_unit_product_id
		)
		request.done (data, textStatus, jqXHR) ->
			remove_saved_product_btn.parent().parent().remove()
			Materialize.toast('Product removed', 2000, 'red')
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			alert "Error"
			return
		return
	
	$('#package-name').keyup ->
		if $(this).val().length > 0
			$("#create-package-btn").css({'visibility':'visible'})
		else
			$("#create-package-btn").css({'visibility':'hidden'})
		return  

	$(document).on "keydown change", ".package-unit-name",->
		is_created = $(this).parent().children('.add-sub-units').attr('data-is-created')
		package_unit_id = $(this).parent().children('.add-sub-units').attr('data-package-unit-id')
		package_unit_name = $(this).val()
		if $(this).val().length > 0
			$(this).parent().children('.add-sub-units').css({'visibility':'visible'})
		else
			$(this).parent().children('.add-sub-units').css({'visibility':'hidden'})
		if is_created == 'true'
			request = $.ajax(
				type: 'POST'
				url: "/api/v2/packages/edit_package_unit"
				dataType: "json"
				data:
					package_unit_id:    package_unit_id
					package_unit_name:  package_unit_name
			)
		return

	$(document).on "click", "#create-package-btn",->
		customer_id = $("#customer-id").val()
		is_created = $(this).attr("data-is-created")
		current_package = $(this)
		if customer_id.length == 0
			Materialize.toast("Please select a customer first", 2000, 'red')
			return false
		if is_created == 'false'
			request = $.ajax(
				type: 'POST'
				url: '/api/v2/packages/package_creation'
				dataType: "json"
				data:
					name:             $("#package-name").val()
					customer_id:      customer_id
			)
			msg = "Package created : #{$("#package-name").val()}"
		else
			request = $.ajax(
				type: 'POST'
				url: '/api/v2/packages/edit_package_name'
				dataType: "json"
				data:
					id:               $("#create-package-btn").data('package-id')
					name:             $("#package-name").val()
					customer_id:      customer_id
			)
			msg = "Package name updated : #{$("#package-name").val()}"
		request.done (data, textStatus, jqXHR) ->
			console.log data
			Materialize.toast("#{msg}", 4000, 'green')
			$("#package-id").val(data.data.id)
			$("#create-package-btn").attr("data-package-id",data.data.id)
			$("#create-package-btn").attr("data-is-created",'true')
			$("#confirm-package-btn").attr("data-package-id",data.data.id)
			contentStr = "<div class='package-units padding-l-35'>"
			contentStr += "<div class='input-group'>"
			contentStr += "<input autocomplete='off' class='package-unit-name margin-t-10 blue-input z-depth-2 form-control float-r' placeholder='Enter unit name' type='text' name='package_unit_name'>"
			contentStr += "<span class='input-group-btn add-sub-units' data-is-created='false' style='visibility:hidden;'>"
			contentStr += "<a class='m-btn green m-btn-low-padding' style='margin-left:20px; margin-top: 8px;'>"
			contentStr += "<i class='mdi-content-add'></i>"
			contentStr += "</a>"
			contentStr += "</span>"
			contentStr += "<span class='input-group-btn add_unit_bom'>"
			contentStr += "<a class='m-btn green m-btn-low-padding right' style='margin-left:10px; margin-top: 8px; width: 36px;'>"
			contentStr += "<i class='fa fa-bold'></i>"
			contentStr += "</a>"
			contentStr += "</span>"
			contentStr += "<span class='input-group-btn remove-package-unit'>"
			contentStr += "<a class='m-btn red m-btn-low-padding right' style='margin-left:10px; margin-top: 8px; width: 36px;'>"
			contentStr += "<i class='mdi-action-highlight-remove'></i>"
			contentStr += "</a>"
			contentStr += "</span>"
			contentStr += "</div>"
			contentStr += "<div class='col-lg-12 add-product-form'></div>"
			contentStr += "</div>"
			current_package.closest('.package-units').append(contentStr)
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			alert "Error"
			return
		return

	$(document).on "click", "#confirm-package-btn",->
		$(".package-unit-name").each ->
			is_created = $(this).parent().children('.add-sub-units').attr('data-is-created')
			package_unit_name = $(this).val()
			package_id = $("#package-id").val()
			parent_unit = $(this).data('parent-unit-id')
			current_package_unit = $(this)
			if is_created == 'false'
				if package_unit_name.length > 0
					request = $.ajax(
						type: 'POST'
						url: '/api/v2/packages/create_package_unit'
						dataType: "json"
						data:
							package_unit_name:  package_unit_name
							parent_unit:        parent_unit
							package_id:         package_id
					)
					request.done (data, textStatus, jqXHR) ->
						current_package_unit.parent().children('.add-sub-units').attr('data-is-created','true')
						current_package_unit.parent().children('.add-sub-units').attr("data-package-unit-id","#{data.data.id}")

						previewRequest = $.ajax(
							type: 'GET'
							url: "/api/v2/packages/#{package_id}.json"
							dataType: "json"
						)

						return
					request.error (jqXHR, textStatus, errorThrown) ->
						alert "Error"
						return
		Materialize.toast("Package submitted successfully, Now finish.",5000,'green')
		return

	$(document).on "click", ".add_unit_bom",->
		package_unit_name = $(this).parent().children('.package-unit-name').val()
		if package_unit_name.length <= 0
			Materialize.toast("Enter a valid unit name", '4000', 'red')
			return false
		is_created = $(this).parent().children('.add-sub-units').attr('data-is-created')
		package_id = $("#package-id").val()
		parent_unit = $(this).parent().children('.package-unit-name').data('parent-unit-id')
		current_unit_bom_btn = $(this)
		if is_created == 'false'
			request = $.ajax(
				type: 'POST'
				url: '/api/v2/packages/create_package_unit'
				dataType: "json"
				data:
					package_unit_name:  package_unit_name
					parent_unit:        parent_unit
					package_id:         package_id
			)
		else
			package_unit_id = $(this).parent().children('.add-sub-units').attr('data-package-unit-id')
			request = $.ajax(
				type: 'POST'
				url: "/api/v2/packages/edit_package_unit"
				dataType: "json"
				data:
					package_unit_id:    package_unit_id
					package_unit_name:  package_unit_name
			)
		request.done (data, textStatus, jqXHR) ->
			console.log data
			subunit_id = data.data.id
			current_unit_bom_btn.parent().children('.add-sub-units').attr("data-is-created",'true')
			current_unit_bom_btn.parent().children('.add-sub-units').attr("data-package-unit-id","#{data.data.id}")
			current_unit_bom_btn.parent().children('.remove-package-unit').attr("data-package-unit-id","#{data.data.id}")
			current_unit_bom_btn.parent().children('.add-sub-units').children('a').removeClass 'green'
			current_unit_bom_btn.parent().children('.add-sub-units').children('a').css('background','#999')
			current_unit_bom_btn.parent().children('.add-sub-units').css("pointer-events","none")

			productRequest = $.ajax(
				type: 'GET'
				url: '/api/v2/packages/required_product_fields'
				dataType: "json"
			)
			productRequest.done (data, textStatus, jqXHR) ->
				console.log data
				data.response = data
				data.subunit_id = subunit_id
				result = JST["templates/packages/product"](data)
				# console.log result
				# $("#product-form").html result
				# current_unit_bom_btn.parent().parent().append result
				current_unit_bom_btn.parent().siblings('.add-product-form').append result
				$('.product_search').each ->
					product = $(this)
					$(this).autocomplete(
						# source: '/products/search_products'
						source: '/packages/search_package_components'
						select: (event, ui) ->
							package_component_id = ui.item.id
							$(this).val ui.item.name
							getproduct = $.ajax(
								type: 'GET'
								url: "/api/v2/packages/package_component_details"
								dataType: "json"
								data:
									package_component_id: package_component_id
							)
							getproduct.done (data, textStatus, jqXHR) ->
								product.parent().parent().children('.outer_product_basic_unit').children('.product_basic_unit').val(data.data.basic_unit_id)
								product.parent().parent().children('.outer_product_category').children('.product_category').val(data.data.category_id)
								product.parent().parent().children('.outer_product_basic_unit').children('.product_basic_unit').attr('disabled', true)
								product.parent().parent().children('.outer_product_category').children('.product_category').attr('disabled', true)
								return
							productRequest.error (jqXHR, textStatus, errorThrown) ->
								alert "Error"
								return  
							false
					).data('uiAutocomplete')._renderItem = (ul, item) ->
						$('<li class="collection-item">').append('<a>' + item.name + '</a>').appendTo ul
				return
			productRequest.error (jqXHR, textStatus, errorThrown) ->
				alert "Error"
				return
			return
		return

	$(document).on "keydown change", ".inner_product_details",->
		$(this).parent().parent().children('.outer_product_basic_unit').children('.product_basic_unit').attr('disabled', false)
		$(this).parent().parent().children('.outer_product_category').children('.product_category').attr('disabled', false)
		return
		 
	$(document).on "click", ".open_product_bom",->
		product_id = $(this).data('product-id')
		contentStr = "<div class='input-group margin-t-15 col-lg-12'>"
		contentStr += "<div class='input-group-addon bom_div'>"
		contentStr += "<input class='form-control bom_product_search ui-autocomplete-input padding-l-r-5' placeholder='Bom' style='height:36px;' type='text' autocomplete='off'>"
		contentStr += "</div>"
		contentStr += "<div class='input-group-addon bom_qty_div'>"
		contentStr += "<input class='form-control bom_qty allow-numeric-only padding-l-r-5 width-60-p' type='text' value='1'>"
		contentStr += "<span class='bom_basic_unit badge margin-t-10'></span>"
		contentStr += "</div>"
		# contentStr += "<div class='input-group-addon bom_basic_unit_div'>"
		# contentStr += "<input class='form-control bom_basic_unit allow-numeric-only' type='text' value='pc'>"
		# contentStr += "</div>"
		contentStr += "<span class='input-group-btn add_bom_btn' data-product-id=#{product_id}>"
		contentStr += "<a class='m-btn green m-btn-low-padding right'>"
		contentStr += "<i class='mdi-content-add'></i>"
		contentStr += "</a>"
		contentStr += "</span>"
		$(this).parent().parent().append contentStr
		$('.bom_product_search').each ->
			$(this).autocomplete(
				source: '/products/search_products'
				select: (event, ui) ->
					$(this).val ui.item.name
					$(this).parent('.bom_div').siblings('.bom_qty_div').children('.bom_basic_unit').html(ui.item.basic_unit)
					false
			).data('uiAutocomplete')._renderItem = (ul, item) ->
				$('<li class="collection-item">').append('<a>' + item.name + '</a>').appendTo ul
		return

	$(document).on "click", ".add_bom_btn",->
		product_id = $(this).data('product-id')
		raw_product_name = $(this).parent().children('.bom_div').children('.bom_product_search').val()
		raw_product_qty = $(this).parent().children('.bom_qty_div').children('.bom_qty').val()
		current_bom_btn = $(this)
		request = $.ajax(
			type: 'POST'
			url: '/api/v2/packages/add_product_composition'
			dataType: "json"
			data:
				product_id:         product_id
				raw_product_name:   raw_product_name
				raw_product_qty:    raw_product_qty
		)
		request.done (data, textStatus, jqXHR) ->
			if data.data.product_found == 'yes'
				current_bom_btn.parent().children('.bom_div').children('.bom_product_search').attr('disabled', true)
				current_bom_btn.parent().children('.bom_qty_div').children('.bom_qty').attr('disabled', true)
				current_bom_btn.html ''
				Materialize.toast("#{raw_product_name} added as ingredients", '4000', 'green')
			else
				Materialize.toast("No product found with #{raw_product_name}", '4000', 'red')
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			alert "Error"
			return
		return

	$(document).on "change", ".menu_cards",->
		selected_menu_card = $(this)
		menu_card_id = $(this).val()
		menu_request = $.ajax(
			type: 'GET'
			url: "/api/v2/menu_cards/#{menu_card_id}.json"
			dataType: "json"
			data:
				resources: 'categories'
		)     
		menu_request.done (menuData, textStatus, jqXHR) ->   
			if menuData.status is "error"
				Materialize.toast(menuData.messages.internal_message, 5000, 'rounded')
			else
				productData =          
					menu_card: menuData.data
				result = JST["templates/packages/menu_categories"](productData)
				console.log result
				console.log selected_menu_card
				console.log selected_menu_card.parent()
				console.log selected_menu_card.parent().parent()
				console.log selected_menu_card.parent().parent().children('.outer_menu_categories')
				selected_menu_card.parent().parent().children('.outer_menu_categories').html result
			return
		menu_request.error (jqXHR, textStatus, errorThrown) ->
			Materialize.toast("Something went wrong, please try after sometime.", 5000)
			return 
		return


