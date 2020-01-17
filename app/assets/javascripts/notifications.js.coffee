# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
	$(document).on "click", ".click_approvable",->
		if($(this).attr('data-approvable-type')=="PurchaseOrder")
			po_id = $(this).attr('data-approvable-id')
			store_id = $(this).attr('data-store-id')
			vendor_name = $(this).data("vendor-name")
			title_string = "Purchase order (Send to : #{vendor_name})"
			$(".approvable-title").html ''
			$(".approvable-title").html(title_string)
			request = $.ajax
									url: "/api/v2/purchase_orders/approval_show?id="+po_id+".json"
									method: 'GET'
									dataType: "json"
			request.done (data, textStatus, jqXHR) ->
				data.purchase_order = data.data
				console.log data.data
				if (data.status=="ok")
					result = JST["templates/notifications/po_details"](data)
					$("#showApprovableModalLabelDetails").html result
					return
				else
					$("#showApprovableModalLabelDetails").html "<h1>Error</h1>"
				return
		else
			$("#showApprovableModalLabelDetails").html "<h1>No Data</h1>"
		return
		request.error (jqXHR, textStatus, errorThrown) ->
			alert "AJAX Error:" + textStatus
			return
		return

	$(document).on "click", ".click_reject_approvable", ->
		reason = prompt('Enter rejection reason:','')
		if reason != null 
			if reason != ''
				approvable_id = $(this).attr('data-approvable-id')
				approvable_type = $(this).attr('data-approvable-type')
				role_id = $(this).attr('data-user-role-id')
				user_id = $(this).attr('data-user-id')
				is_approve = "reject"
				request = $.ajax(
					type: 'POST'
					url: "/api/v2/approvals/update_approval.json"
					dataType: "json"
					data:
						approvable_id: approvable_id
						approvable_type: approvable_type      
						role_id: role_id
						user_id: user_id
						is_approve: is_approve
						reason: reason
				)
				window.location = "/notifications/approval_alerts"
			else
				alert "Please, Enter valid rejection reason !"
			return
		else
			alert "Please, Enter valid rejection reason !"
		return

	$(document).on "click", ".click_accept_approvable", ->
		conf = confirm('Do you really want approve?')
		if conf == true 
			reason = ''
			approvable_id = $(this).attr('data-approvable-id')
			approvable_type = $(this).attr('data-approvable-type')
			role_id = $(this).attr('data-user-role-id')
			user_id = $(this).attr('data-user-id')
			is_approve = "true"
			request = $.ajax(
				type: 'POST'
				url: "/api/v2/approvals/update_approval.json"
				dataType: "json"
				data:
					approvable_id: approvable_id
					approvable_type: approvable_type      
					role_id: role_id
					user_id: user_id
					is_approve: is_approve
					reason: reason
			)
			window.location = "/notifications/approval_alerts"
		else
			window.location = "/notifications/approval_alerts"
		return