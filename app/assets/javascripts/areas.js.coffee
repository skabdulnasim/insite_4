$(document).ready ->
	load_user_by_role = (role_id) ->
		area_id = if $('#area_id').data('area-id') == undefined then '' else $('#area_id').data('area-id')
		request = $.ajax(url: "/areas/fetch_users.json?role=#{role_id}&area_id=#{area_id}")
		request.done (data, textStatus, jqXHR) ->
			data.type_info = data
			data.present_user_id = $("#user_id").val()
			result = JST["templates/areas/select_user"](data)
			$("#ajax-user-section").html result
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			$('#ajax-user-section').html('')
			return
		return 
	role_id = $("#allocted_role_id").data("role-id")
	if role_id != undefined
		$("#role_id > option").each ->
			if role_id == parseInt($(this).val())
				$(this).attr("selected","selected")
				load_user_by_role(role_id)

	$("#role_id").on "click", ->
		role_id = $(this).val()
		$('#ajax-user-section').html('')
		if role_id.length>0
			load_user_by_role(role_id)
		else
			$('#ajax-user-section').html('')
		return
		
	$(document).on "change","#users",event, ->
		$("#user_id").val($("#users option:selected").val())
		return
	return


