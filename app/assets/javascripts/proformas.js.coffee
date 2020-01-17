$(document).ready ->
	$(document).on "click", ".proforma-quickview", ->
		proforma_id = $(this).data("proforma-id")
		loader_data = {loader_type: 'color-spinner'}
		loader = JST['templates/loader'](loader_data)
		$("#proforma_quickinfo_#{proforma_id}").html loader
		request = $.ajax(url: "/api/v2/proformas/#{proforma_id}.json")
		request.done (data, TextStatus, jqXHR) ->
			console.log data
			data.response = data.data
			result = JST["templates/proformas/order_details"](data)
			$("#proforma_quickinfo_#{proforma_id}").html result
			return
		request.error (jqXHR, TextStatus, errorThrown) ->
			$("#proforma_quickinfo_#{proforma_id}").html TextStatus
		return
	$(document).on "click", ".generate-order-details", (event) ->
		generate_order_details($(this).data("proforma-id"), $(this).data("page-type"))

	generate_order_details = (proforma_id, page_type) ->
		console.log(proforma_id)
		request = $.ajax(url: "/api/v2/proformas/#{proforma_id}.json")
		request.done (data, TextStatus, jqXHR) ->
			if page_type is "a4"
				data.page_size = 640
			else if page_type is "a5"
				data.page_size = 440
			data.response = data.data
			print_order_result = JST["templates/orders/print_order_details"](data)
			$("#orderModalBody").html print_order_result
		request.error (jqXHR, TextStatus, errorThrown) ->
			console.log 'sadasd'
		return

	$(document).on "click", ".print_proforma", (event) ->
    #open new window set the height and width =0,set windows position at bottom
    a = window.open()
    #write gridview data into newly open window
    a.document.write document.getElementById('orderModalBody').innerHTML
    a.document.close()
    a.focus()
    #call print
    a.print()
    a.close()
    false
    return

	return



		
