# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
	$(document).on "click", ".denomination-quickview", ->
		stock_transaction_id = $(this).data("transaction-id")
		request = $.ajax(
      type: 'GET'
      url: "/api/v2/cash_handlings/#{stock_transaction_id}.json"
      dataType: "json"
    )
		request.done (data, textStatus, jqXHR) ->
			data.responseData = data
			console.log data.responseData
			
			result = JST["templates/cash_handlings/denomination_details"](data)
			$("#denomination_quickinfo_#{stock_transaction_id}").html result 
			return
		request.error (jqXHR, textStatus, errorThrown) ->
      $("#denomination_quickinfo_#{stock_transaction_id}").html textStatus
      return
    return


  

