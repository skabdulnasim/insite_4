$(document).ready ->

############################### AJAX FETCH MENU CARD ######################
	$("#resource_section_id").on "change", ->
		sectionId = $("#resource_section_id option:selected" ).val()
		request = $.ajax(url: "/resources/fetch_active_menu_cards/?section_id="+sectionId)
		request.done (data, textStatus, jqXHR) ->
			data.menu_cards = data
			result = undefined
			result = JST["templates/resources/menu_card_options_dropdown"](data)
			$("#resource_menu_card_id").html result
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			$("#_label_toggle_section").html ""
			$("#_select_toggle_section").html ""
			return
		requestResource = $.ajax(url: "/resources/fetch_section_resources/?section_id="+sectionId)
		requestResource.done (data, textStatus, jqXHR) ->
			data.resources = data
			result = undefined
			result = JST["templates/resources/resource_options_dropdown"](data)
			$("#resource_parent_resource_id").html result
			return
		requestResource.error (jqXHR, textStatus, errorThrown) ->
			$("#resource_parent_resource_id").html ""
			return 
		return
############################### AJAX FETCH MENU CARD END ######################

	$(document).on 'click', 'form .add_fields', (event)->
		time = new Date().getTime()
		regexp = new RegExp($(this).data('id'), 'g')
		$(this).before($(this).data('fields').replace(regexp,time))
		event.preventDefault()

############################### AJAX FETCH MENU PRODUCT ######################
	$("#resource_menu_card_id").on "change", ->
		menu_card_id = $("#resource_menu_card_id option:selected" ).val()
		request = $.ajax(url: "/resources/fetch_active_menu_products/?menu_card_id="+menu_card_id)
		request.done (data, textStatus, jqXHR) ->
			data.menu_products = data
			result = undefined
			result = JST["templates/resources/menu_product_options_dropdown"](data)
			$("#resource_menu_product_id").html result
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			$("#resource_menu_product_id").html ""
			return
		return