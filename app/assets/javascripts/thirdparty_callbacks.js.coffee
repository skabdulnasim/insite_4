$(document).ready ->
	renderJson = (json_data) ->
		try
			input = eval('(' + json_data + ')')
		catch error
			return alert('Cannot eval JSON: ' + error)
		options = 
			collapsed: false
			rootCollapsable: true
			withQuotes: false
			withLinks: false
		$('#json-renderer').jsonViewer input, options
		return

	# renderJson('{	  "id": 1001,	  "type": "donut",	  "name": "Cake",	  "description": "https://en.wikipedia.org/wiki/Doughnut",	  "price": 2.55,	  "available": {	    store: 42,	    warehouse: 600	  },	  "toppings": [	    { "id": 5001, "type": "None" },	    { "id": 5002, "type": "Glazed" },	    { "id": 5005, "type": "Sugar" },	    { "id": 5003, "type": "Chocolate" },	    { "id": 5004, "type": "Maple" }	  ]}')

	$(document).on "click", ".click_callback",->
		callback_id = $(this).attr('data-callback-id')
		# $("#json-renderer").html '<img src="/assets/loader_blue.gif" style="width: 350px;">'
		$("#json-renderer").html ''
		request = $.ajax
								url: "/api/v2/thirdparty_callbacks/"+callback_id+".json"
								method: 'GET'
								dataType: "json"
		request.done (data, textStatus, jqXHR) ->
			console.log data.data.data
			renderJson(data.data.data)
		request.error (jqXHR, textStatus, errorThrown) ->
			alert "AJAX Error:" + textStatus
			return
		return