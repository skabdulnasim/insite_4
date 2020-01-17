# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->

	$(document).on "click", '.customer_account_transaction', (event) ->
		customer_id = $(this).data('customer-id')
		customer_name = $(this).data('customer-name')
		customer_acc_no = $(this).data('customer-acc-no')
		request = 
			$.ajax
				url: "/api/v2/customers/account_transaction_history"
				method: 'GET'
				dataType: "json"
				data:
					customer_id: customer_id
		request.done (data, textStatus, jqXHR) ->
			data.account_transactions = data.data
			console.log data
			result = JST["templates/financial_account_transactions/quick_details"](data)
			$("#customer_account_transaction_details").html result
			contentStr = "<span class='font-w-400'>#{customer_name}</span>"
			if customer_acc_no.toString().length > 0
				contentStr += "<span class='margin-l-22 m-label green font-w-400'>#{customer_acc_no}</span>"
			else
				contentStr += "<span class='margin-l-22 m-label green font-w-400'>No account found</span>"
			contentStr += "<span class='float-r' style='margin-top:-12px;'>"
			contentStr += "<a class='m-btn indigo margin-l-5' href='/financial_accounts/account_details.csv?customer_id=#{customer_id}&account_holder_type=Customer'>"
			contentStr += "<i class='mdi-file-file-download left'></i>"
			contentStr += "CSV"
			contentStr += "</a>"
			contentStr += "</span>"
			contentStr += "<div class='margin-t-5'></div>"
			contentStr += "<div class='divider'></div>"
			$("#customer-account").html contentStr
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			alert "AJAX Error:" + textStatus
			return
		return