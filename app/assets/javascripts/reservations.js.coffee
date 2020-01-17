# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

refetch_events_and_close_dialog = ->
  $('#calendar').fullCalendar 'refetchEvents'
  $('.dialog:visible').dialog 'destroy'
  return

showPeriodAndFrequency = (value) ->
  switch value
    when 'Daily'
      $('#period').html 'day'
      $('#frequency').show()
    when 'Weekly'
      $('#period').html 'week'
      $('#frequency').show()
    when 'Monthly'
      $('#period').html 'month'
      $('#frequency').show()
    when 'Yearly'
      $('#period').html 'year'
      $('#frequency').show()
    else
      $('#frequency').hide()
  return

$(document).on "keyup keydown", "#customer", ->
	$(".update-profile").show()
	mobile_no = $("#customer_mobile").val()
	if mobile_no.length == 10
		request = undefined
		request = $.ajax(url: "/api/v2/customers/find_by_login.json?login="+mobile_no)
		request.done (data, textStatus, jqXHR) ->
			console.log data
			$("#customer_id").val(data.customer_id)
			$("#profile_id").val(data.id)
	return

$(document).on "click", ".update-profile", ->
	user_id = $("#customer_id").val()
	profile_id = $("#profile_id").val()
	user_name = $("#customer").val()
	customer_param = { "customer" : { "customer_profile_attributes" : { "customer_name" : "#{user_name}", "id" : "#{profile_id}" } } }
	if user_name != ""
		request = undefined
		request = $.ajax(
			type: 'POST',
			headers: {"X-HTTP-Method-Override": "PUT"},
			url: "/customers/"+user_id,
			data: customer_param
		)
		request.done (data, textStatus, jqXHR) ->
			$(".update-profile").hide()
	return

$(document).ready ->
	$(".update-profile").hide()
	$("#resource_id").val('')
	$("#reservation_date").val('')
	$('.add-details').hide()
	$('.show_details').on "click", ->
		resource_id = $("#resource_id").val()
		if resource_id == ''
			Materialize.toast("Select Resource first", 3000)
		else
			$("#new-reservation").modal "show"
		return
	$('#calendar').fullCalendar
		editable: true
		header:
      left: 'prev,next today',
      center: 'title',
      right: 'month,agendaWeek,agendaDay'
		defaultView: 'agendaWeek'
		height: 600
		slotMinutes: 15
		loading: (bool) ->
		  if bool
		    $('#loading').show()
		  else
		    $('#loading').hide()
		  return
		events: '/api/restapi/get_reservations.json'
		timeFormat: 'h:mm tt{ - h:mm tt} '
		dragOpacity: '0.5'
		eventDrop: (event, dayDelta, minuteDelta, allDay, revertFunc) ->
		  return
		eventResize: (event, dayDelta, minuteDelta, revertFunc) ->
		  return
		eventClick: (event, jsEvent, view) ->
		  return

	$('div.bhoechie-tab-menu>div.list-group>a').on "click", (e) ->
    e.preventDefault()
    $(this).siblings('a.active').removeClass 'active'
    $(this).addClass 'active'
    index = $(this).index()
    $('div.bhoechie-tab>div.bhoechie-tab-content').removeClass 'active'
    $('div.bhoechie-tab>div.bhoechie-tab-content').eq(index).addClass 'active'
    return	  
	
	request = undefined
	request = $.ajax(url: "/api/restapi/get_resources.json")
	request.done (data, textStatus, jqXHR) ->
		data.responseData = data
		result = JST["templates/reservations/list_resources"](data)
		$(".resource").html result
		return	  

	$(".register-new-customer").on "click", ->
		fname = $("#customer_customer_profile_attributes_firstname").val()
		lname = $("#customer_customer_profile_attributes_lastname").val()
		address = $("#customer_customer_profile_attributes_address").val()
		mobile_no = $("#customer_mobile_no").val()
		dob = $("#customer_customer_profile_attributes_dob").val()
		if fname == ''
			$("#customer_customer_profile_attributes_firstname").focus()
			$("#customer_customer_profile_attributes_firstname").addClass('error-rais')
		else
			$("#customer_customer_profile_attributes_firstname").removeClass('error-rais')
		if lname == ''
			$("#customer_customer_profile_attributes_lastname").focus()
			$("#customer_customer_profile_attributes_lastname").addClass('error-rais')
		else
			$("#customer_customer_profile_attributes_lastname").removeClass('error-rais')	
		if address == ''
			$("#customer_customer_profile_attributes_address").focus()
			$("#customer_customer_profile_attributes_address").addClass('error-rais')
		else
			$("#customer_customer_profile_attributes_address").removeClass('error-rais')		
		if mobile_no == '' || mobile_no < 10
			$("#customer_mobile_no").focus()
			$("#customer_mobile_no").addClass('error-rais')
			return false
		else
			$("#customer_mobile_no").removeClass('error-rais')	
		if dob == ''
			$("#customer_customer_profile_attributes_dob").focus()
			$("#customer_customer_profile_attributes_dob").addClass('error-rais')
		else
			$("#customer_customer_profile_attributes_dob").removeClass('error-rais')	
		return
		
	$("#customer_mobile").on "change keyup", ->
		mobile_no = $(this).val()
		if mobile_no.length == 10
			request = undefined
			request = $.ajax(url: "/api/v2/customers/find_by_login.json?login="+mobile_no)
			request.done (data, textStatus, jqXHR) ->
				console.log data
				$('.add-details').show()
				$("#customer_id").val(data.customer_id)
				$("#profile_id").val(data.id)
				$("#customer_unique_id").val(data.customer.customer_unique_id)
				if data.lastname == ""
					$("#customer").val(data.firstname)
				else
					$("#customer").val(data.firstname+" "+data.lastname)
			request.error (jqXHR, textStatus, errorThrown) ->
				$("#new-reservation").modal "hide"
				$("#register-customer").modal "show"
				$("#customer_mobile_no").val(mobile_no)
		return

	$("#date").on "change select", ->
		reservation_date = $(this).val()
		request = undefined
		request = $.ajax(url: "/api/restapi/get_resources.json?reservation_date="+reservation_date)
		request.done (data, textStatus, jqXHR) ->
			data.responseData = data
			result = JST["templates/reservations/list_resources"](data)
			$(".resource").html result
		return

	$(".print_token").on "click", ->
		bill_id = $(this).data("bill-id")
		currency = $(this).data("currency")
		generate_invoice bill_id,currency
		return

	$(".reservation-quickview").on "click", ->
		currency = $(this).data("currency")
		reservation_id = $(this).data("reservation-id")
		request = $.ajax(
			type: 'GET'
			url: "/api/v2/reservations/#{reservation_id}.json"
			dataType: "json"
		)
		request.done (responseData, textStatus, jqXHR) ->
			data = responseData.data
			data.response = data
			data.currency = currency
			result = JST["templates/reservations/quick_details"](data)	
			$("#reservation_quickinfo_#{reservation_id}").html result
			return

	$(document).on "click", ".cancel_update_bill", ->		
		$('.settlement_mode').prop 'checked', false
		$('.amount_cash').val ''
		$('.amount_card').val ''
		$('.card_no').val ''
		$('#paymentModal').modal 'hide' 
		return

	$(document).on "click", ".reservation-settlement-link", ->
		$('.cash_settlement_mode').prop 'checked', true
		bill_amount = $(this).data("bill-amount")
		$('.amount_cash').val bill_amount
		bill_id = $(this).data("bill-id")
		currency = $(this).data("currency")
		email_id = $(".current_user_email").val()
		request = $.ajax(
			type: "GET"
			url: "/api/v2/bills/#{bill_id}.json"
			dataType: "json"
		)
		request.done (data, textStatus, jqXHR) ->
			data.bill_response = data.data
			data.currency = currency
			data.email_id = email_id
			settlement_details_result = JST["templates/settlement/settlement_details"](data)
			$("#settlement_details").html settlement_details_result
			$('#paymentModal').modal 'show' 
			return		

	$(document).on "change", "#slot_id", ->
		date = $("#reservation_date").val()
		resource_id = $("#resource_id").val()
		slot_id = $(this).val()
		request = undefined
		request = $.ajax(url: "/api/restapi/get_available_slot.json?resource="+resource_id+"&date="+date+"&slot_id="+slot_id)
		request.done (data, textStatus, jqXHR) ->
			$("#start_time").val(data.next_start_time)
			$("#end_time").val(data.next_end_time)
		return	

	place_order = (cart_items, email_id, unit_id, deliverable_type, deliverable_id, consumer_type, consumer_id, currency, source, reservation_id)->
		request = $.ajax(
      type: 'POST'
      url: "/api/v2/orders"
      dataType: "json"      
      data:
        email:            email_id
        device_id:        'YOTTO05'
        order:
          unit_id:          unit_id
          source:           'fos'        
          device_id:        'YOTTO05'
          consumer_type:    consumer_type
          consumer_id:      consumer_id
          deliverable_type: deliverable_type
          deliverable_id:   deliverable_id
          order_details_attributes: cart_items
    )
		request.done (data, textStatus, jqXHR) ->
			console.log data
			if data.status is "ok"
				#Materialize.toast(data.messages.internal_message, 2000)
				bill_request = $.ajax(
          type: 'POST'
          url: "/api/v2/bills"
          dataType: "json"   
          data:
            email:            email_id
            device_id:        'YOTTO05'
            bill:
              biller_id:        consumer_id
              biller_type:      consumer_type
              pax:              '1'
              unit_id:          unit_id
              deliverable_id:   deliverable_id
              deliverable_type: deliverable_type
              device_id:        "YOTTO05"
              customer_id: 		deliverable_id
              bill_orders_attributes: [
                {
                  order_id: data.data.id
                }
              ]
        ) 
				bill_request.done (data, textStatus, jqXHR) ->
					if data.status is "ok"
            Materialize.toast(data.messages.internal_message, 2000)
            reservation_params = {"reservation": {"bill_id" : "#{data.data.id}", "status" : "1"}}
            request_reservation_update = undefined
            request_reservation_update = $.ajax(
            	type: 'PUT'
            	url: "/reservations/#{reservation_id}.json"
            	dataType: "json"
            	async: false
            	data: reservation_params
            )
            request_reservation_update.done (object, textStatus, jqXHR)->
            	$('.cash_settlement_mode').prop 'checked', true
            	bill_amount = data.data.grand_total
            	$('.amount_cash').val bill_amount
	            $('#paymentModal').modal 'show' 
	            data.bill_response = data.data
	            data.currency = currency
	            data.email_id = email_id
	            settlement_details_result = JST["templates/settlement/settlement_details"](data)
	            $("#settlement_details").html settlement_details_result

	$(document).on "click", ".get_token", ->
		Materialize.toast('Processing your request...', 6000,'')
		menu_card_id = $(this).data("menu-card")
		resource_id = $(this).data("resource-id")
		reservation_id = $(this).data("reservation-id")
		email_id = $(this).data("email-id")	
		unit_id = $(this).data("unit-id")
		deliverable_type = "Customer"
		deliverable_id = $(this).data("customer-id")
		currency = $(this).data("currency")
		consumer_type = "user"
		consumer_id = $(this).data("user-id")
		source = "fos"
		request = undefined
		request = $.ajax(
			type: "GET"
			url: "/api/v2/menu_cards/#{menu_card_id}.json"
			dataType: "json"
		)
		request.done (data,textStatus,jqXHR) ->
			console.log data.data.products
			data.menu_response = data.data
			menu_product_result = JST["templates/menu_products/products"](data)
			$("#menu_product").html menu_product_result
			$("#orderModal").modal 'show'
			cart_items = new Array
			$(".cofirm-order").on "click", ->
				if $('.menu_products:checkbox:checked').length == 0
					$("#overlay").html "Please Select menu item first"
					$("#overlay").show()
					$("#overlay").delay(3000).fadeOut()
				else	
					$("#orderModal").modal 'hide'
					$('.menu_products:checkbox:checked').map ->
          	item = 
          		menu_product_id: $(this).val()
          		quantity: 1
          	cart_items.push item 
          place_order cart_items, email_id, unit_id, deliverable_type, deliverable_id, consumer_type, consumer_id, currency, source, reservation_id
		return

	make_bill_settlement = (email_id, bill_id, client_id, client_type, payment_data, currency) ->
    settlement_request = $.ajax(
      type: 'POST'
      url: "/api/v2/settlements"
      dataType: "json"
      data:
        email:            email_id
        device_id:        'YOTTO05'
        settlement:
          bill_id       : bill_id
          tips          : 0
          client_id     : client_id
          client_type   : client_type
          device_id     : 'YOTTO05'
          payments_attributes: payment_data
    )
    settlement_request.done (data, textStatus, jqXHR) ->
      if data.status is "ok"
        Materialize.toast(data.messages.internal_message, 2000)
        generate_invoice(bill_id, currency)
      else
        Materialize.toast(data.messages.internal_message, 2000)
    settlement_request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("#{textStatus}", 5000)
      return
    return		

  generate_invoice = (bill_id, currency) ->
  	request = $.ajax(
  		type: "GET"
  		url: "/api/v2/bills/#{bill_id}"
  		dataType: "json"
  		data:
  			resources: 'order_items,tax_details,discount_details,payment_details,delivery_details,unit_details,reservation_details'
  	)
  	request.done (data, textStatus, jqXHR) ->
  		console.log data
  		data.response = data.data
  		data.currency = currency
  		token_result = JST["templates/settlement/token"](data)
  		$("#token_content").html token_result
  		$('#paymentModal').modal 'hide'
  		$("#tokenModal").modal 'show'	
  		
	$(document).on "click", '#bill_settlement', (event) -> 
    email_id = $(this).data("email-id")
    currency = $(this).data("currency")
    client_id = $(this).data("client-id")
    client_type = 'User'  
    bill_id = parseFloat($(this).data("bill-id"))
    bill_amount = parseFloat($(this).data("bill-amount"))
    payment_data = new Array
    settled_amount = 0
    $('input[name="settlement_mode[]"]:checked').map ->
      payment_mode = $(this).val()
      if payment_mode is "cash"
        cash_amount = parseFloat($("#cash_settlement_amount").val())
        arr =
          paymentmode_type : 'Cash'
          paymentmode_attributes :
            amount          : cash_amount
            balance_return  : 0
            tendered_amount : cash_amount
        payment_data.push arr
        settled_amount += cash_amount
      else if payment_mode is "card"
        card_amount = parseFloat($("#card_settlement_amount").val())
        card_no = $("#card_number").val()
        card_type = $("#card_type").val()
        card_merchandiser = $("#card_merchandiser").val()
        arr =
          paymentmode_type : 'Card'
          paymentmode_attributes :
            amount       : card_amount
            no           : card_no
            valid_upto   : null
            card_type    : card_type
            bank         : null
            cvv          : null
            merchandiser : card_merchandiser
            name_on_card : null
        payment_data.push arr
        settled_amount += card_amount
    # Place order here if cart items present
    if settled_amount != bill_amount
      Materialize.toast("Oops! payable amount and settled amount is not matching.", 3000,'round')
      $('.modal-content').addClass('active')
      return
    else
      # API Call
      make_bill_settlement email_id, bill_id, client_id, client_type, payment_data, currency
    return	

  $(document).on "click", ".generate-invoice", (event) ->
    make_print($(this).data("bill-id"), $(this).data("currency"), $(this).data("page-type"))
    return  

  # Generate Invoice
  make_print = (bill_id, currency, page_type) ->
    request = $.ajax(
      type: 'GET'
      url: "/api/v2/bills/#{bill_id}"
      dataType: "json"
      data:
        resources: 'order_items,tax_details,discount_details,payment_details,delivery_details,unit_details,reservation_details'
    )
    request.done (data, textStatus, jqXHR) ->
      console.log data
      $("#invoiceModalBody").html ''
      if page_type is 'a4'
        data.page_size= 640
      else if page_type is 'a5'
        data.page_size= 400
      else
        data.page_size= 540
      data.response = data.data
      data.currency = currency
      invoice_result = JST["templates/reservations/invoice_details"](data)
      $("#invoiceModalBody").html invoice_result
    request.error (jqXHR, textStatus, errorThrown) ->
      console.log textStatus
    return  

   # Print function
  $(document).on "click", ".print", (event) ->
    #open new window set the height and width =0,set windows position at bottom
    a = window.open()
    #write gridview data into newly open window
    a.document.write document.getElementById('DivIdToPrint').innerHTML
    a.document.close()
    a.focus()
    #call print
    a.print()
    a.close()
    $('#tokenModal').modal('toggle')
    false
    return 

  $(document).on "click", ".print-invoice", (event) ->
    #open new window set the height and width =0,set windows position at bottom
    a = window.open()
    #write gridview data into newly open window
    a.document.write document.getElementById('DivIdToPrintInvoice').innerHTML
    a.document.close()
    a.focus()
    #call print
    a.print()
    a.close()
    false
    return   

	$(document).on "change", "#resource", ->
		reservation_date = $("#date").val()
		resource_id = $(this).val()
		$("#reservation_date").val(reservation_date)
		$("#resource_id").val(resource_id)
		$('#calendar').html ""
		$('#calendar').fullCalendar
			editable: true
			header:
	      left: 'prev,next today',
	      center: 'title',
	      right: 'month,agendaWeek,agendaDay'
			defaultView: 'month'
			height: 600
			slotMinutes: 15
			loading: (bool) ->
			  if bool
			    $('#loading').show()
			  else
			    $('#loading').hide()
			  return
			events: '/api/restapi/get_reservations.json?resource='+resource_id+'&date='+reservation_date
			timeFormat: 'h:mm tt{ - h:mm tt} '
			dragOpacity: '0.5'
			eventDrop: (event, dayDelta, minuteDelta, allDay, revertFunc) ->
			  return
			eventResize: (event, dayDelta, minuteDelta, revertFunc) ->
			  return
			eventClick: (event, jsEvent, view) ->
			  return
		request = undefined
		request = $.ajax(url: "/api/restapi/get_slots.json?reservation_date="+reservation_date+"&resource_id="+resource_id)
		request.done (data, textStatus, jqXHR) ->
			data.responseData = data
			result = JST["templates/reservations/show_slots"](data)
			$(".slot").html result
			$("#selectable").selectable({
				selected: ( event, ui ) ->
					id = ui.selected.dataset['id']
					$("#slot_id").val(id)
					mobile_no = $("#customer_mobile").val()
					request = undefined
					request = $.ajax(url: "/api/v2/customers/find_by_login.json?login="+mobile_no)
					request.done (data, textStatus, jqXHR) ->
						$("#customer_id").val(data.customer_id)
			})
	return


	