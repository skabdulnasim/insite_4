# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
	resource_id_array=[]
	
	$(".pre_allocated_list").each ->
		html_str = "<li class='token-input-token-facebook token-input-highlighted-token-facebook' id='list_item"+$(this).data('item-id')+"'>"
		html_str += "<p>#{$(this).data('item-name')}</p>"
		html_str+="<span class='token-input-delete-token-facebook delete-sku-token remove_token' data-item-id="+$(this).data('item-id')+"><span></li>"
		$(".allocation_item_container").append(html_str)
		resource_id_array.push($(this).data("item-id"))
		$("#hidden_item_ids").val(resource_id_array)
		console.log(resource_id_array)

	$(document).on "click",".selectable_item_list", ->
		console.log($(this).data("item-id"))
		if ($(this).children().first().hasClass("fa-plus"))
			toggle_to_add($(this))
			add_into_resource_id_array($(this))
		else
			toggle_to_remove($(this))
			remove_from_resource_id_array($(this))
		return

	$(document).on "click",".remove_token",->
		action_button = $(".action_for_resource#{$(this).data('item-id')}")
		if confirm("are you sure")
			$(".action_for_selectable_item_list#{$(this).data('item-id')}").trigger("click")
			remove_from_resource_id_array($(this))
			$(this).parent().remove()
		return	
	
	toggle_to_add = (obj) ->
		html_str = "<li class='token-input-token-facebook token-input-highlighted-token-facebook' id='list_item"+obj.data('item-id')+"'>"
		html_str += "<p>#{obj.data('item-name')}</p>"
		html_str+="<span class='token-input-delete-token-facebook delete-sku-token remove_token' data-item-id="+obj.data('item-id')+">x<span></li>"
		$(".allocation_item_container").append(html_str)
		obj.removeClass("green")
		obj.addClass("red")
		obj.children().first().removeClass("fa-plus")
		obj.children().first().addClass("fa-minus")
		return resource_id_array

	toggle_to_remove = (obj) ->
		console.log(obj)
		$("#list_item#{obj.data('item-id')}").remove()
		obj.removeClass("red")
		obj.addClass("green")
		obj.children().first().removeClass("fa-minus")
		obj.children().first().addClass("fa-plus")
		return resource_id_array

	add_into_resource_id_array = (obj) ->
		resource_id_array.push(obj.data("item-id"))
		$("#hidden_item_ids").val(resource_id_array)
		console.log(resource_id_array)

	remove_from_resource_id_array = (obj) ->
		resource_temp = resource_id_array
		resource_id_array = []
		for val in resource_temp
			if val != obj.data("item-id")
				resource_id_array.push(val)
		console.log(resource_id_array)
		$("#hidden_item_ids").val(resource_id_array)

	

