# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
###################################### fetch units under a unit type and show in a dropdown##############################
	$(".dn").hide()
	$("#reg_unittype_id").on "change", ->
		currentSelection = $(this).val() 
		# alert currentSelection    
		request = undefined
		request = $.ajax(url: "/unittypes/#{currentSelection}/fetch_units.json")
		#alert(d);
		request.done (data, textStatus, jqXHR) ->
			# alert JSON.stringify(data)
			data.type_info = data
			#alert data.type_info[1].id
			result = undefined
			result = JST["templates/units/select_unit"](data)
			$(".dn").show()
			$(".dn1").hide()
			$("#text-selector").html result
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			#alert "AJAX Error:" + textStatus
			$(".dn").hide()
			return 
		return
########################################################################################################################  

######################### fetch parent user and show in a dropdown##############################
	# $("#role_id").on "change", ->
	#   document.getElementById('ajax-parent-user-section').innerHTML = ""
	#   currentSelection = $('#role_id option:selected').text()
	#   if $('#role_id').val().length>0
	#     if currentSelection.localeCompare("owner") != 0    
	#       request = undefined
	#       request = $.ajax(url: "/users/fetch_parent_users.json?role=#{currentSelection}")
	#       request.done (data, textStatus, jqXHR) ->
	#         data.type_info = data
	#         result = undefined
	#         result = JST["templates/units/select_parent_user"](data)
	#         $("#ajax-parent-user-section").html result
	#         return
	#       request.error (jqXHR, textStatus, errorThrown) ->
	#         document.getElementById('ajax-parent-user-section').innerHTML = ""
	#         return 
	#       return
	#     else
	#       document.getElementById('ajax-parent-user-section').innerHTML = ""
	#       document.getElementById("user_parent_user_id").value=""; 
	#   else
	#     document.getElementById('ajax-parent-user-section').innerHTML = ""


	$("#role_id").on "change", ->
		role_id = $(this).val()
		$('#ajax-parent-user-section').html('')
		if role_id.length>0
			request = $.ajax(url: "/users/fetch_parent_users.json?role=#{role_id}")
			request.done (data, textStatus, jqXHR) ->
				data.type_info = data
				result = JST["templates/units/select_parent_user"](data)
				$("#ajax-parent-user-section").html result
				return
			request.error (jqXHR, textStatus, errorThrown) ->
				$('#ajax-parent-user-section').html('')
				return
		else
			$('#ajax-parent-user-section').html('')
		return

########################################################################################################################
	
	
	$("#profile_address").on "keyup click", ->
		currentSelection = $(this).val()
		#alert currentSelection
		request_addrs = undefined
		request_addrs = $.ajax(url: "/users/fetch_address_details?address="+currentSelection)  
		request_addrs.done (data, textStatus, jqXHR) ->
			console.log data
			locality = data.locality[0]
			city = data.city
			state = data.state
			pincode = data.pincode
			country = data.country
			$("#profile_zip_code").val(pincode)
			$("#profile_city").val(city)
			#$("#unit_locality").val(sub_city)
			$("#profile_state").val(state)
			$("#profile_country").val(country)
			return
		request_addrs.error (jqXHR, textStatus, errorThrown) ->
			alert "AJAX Error:" + textStatus
			return 
		return

########################## update user custom sync ##########################
	$('.update_custom_sync').click ->
		user_id = $(this).data('user-id')
		active = $(this).attr('data-value-active')
		inactive = $(this).attr('data-value-inactive')
		custom_sync_value = if @checked then active else inactive
		request = $.ajax(
			type: 'POST'
			url: '/users/update_custom_sync'
			dataType: "json"
			data:
				custom_sync_value: custom_sync_value
				user_id: user_id
		)
		request.done (data, textStatus, jqXHR) ->
			Materialize.toast("Custom sync updated to: #{custom_sync_value}", 5000)
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			alert "Error"
			return
		return


	return