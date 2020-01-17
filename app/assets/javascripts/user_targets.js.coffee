# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->

	# Initializing the product form wizard
	$('#wizard_vertical').steps
		headerTag: 'h3'
		bodyTag: 'section'
		transitionEffect: 'fade'
		stepsOrientation: 'vertical'
		showFinishButtonAlways: true
		enableAllSteps: true
		onStepChanging: (event, currentIndex, newIndex) ->
			true  
		onFinished: (event, currentIndex) ->
			form = $('.target_set_form')
			form.submit()
			return

	# $("#monthly_target").hide()

	$('.target_amount').on "keyup",->
		child_user_id = $(this).data('child-user-id')
		child_user_name = $(this).data('child-user-name')
		parent_user_id = $(this).data('parent-user-id')
		parent_target_id = $(this).data('parent-target-id')
		target_id = $(this).data('target-id')
		target_amount = parseFloat($(this).val())
		child_target_sum = 0
		if target_amount <= 0 or isNaN(target_amount)
			Materialize.toast("Please provide some amount", 3000, "red")
			$(".user-target-list").find("#li_user_#{child_user_id}").remove()
		else
			if $("#li_user_#{child_user_id}").length
				$("#child_user_target_amount_#{child_user_id}").html target_amount
				$("#target_amount_#{child_user_id}").val target_amount
			else
				contentStr = "<li class='collection-item padding-5' id='li_user_#{child_user_id}'><div>"
				contentStr += "<input type='checkbox' name='checked_child_users[]' value='#{child_user_id}' id='child_user_#{child_user_id}' checked>"
				contentStr += "<label for='child_user_#{child_user_id}' class='font-sz-11'>#{child_user_name}</label>"
				contentStr += "<span class='secondary-content font-sz-11'><span id='child_user_target_amount_#{child_user_id}'>#{target_amount}</span></span>"
				contentStr += "<input type='hidden' name='target_amount_#{child_user_id}' value='#{target_amount}' id='target_amount_#{child_user_id}'/>"
				contentStr += "<input type='hidden' name='parent_user_#{child_user_id}' value='#{parent_user_id}' id='parent_user_#{child_user_id}'/>"
				contentStr += "<input type='hidden' name='parent_target_id_#{child_user_id}' value='#{parent_target_id}' id='parent_target_id_#{child_user_id}'/>"
				contentStr += "<input type='hidden' name='target_id_#{child_user_id}' value='#{target_id}' id='target_id_#{child_user_id}'/>"
				contentStr += "</div></li>"
				$(".no-user-selected").hide()
				$(".user-target-list").prepend(contentStr)

		$(".child_target_"+parent_user_id).each ->
			if !isNaN(parseFloat($(this).val()))
				child_target_sum += parseFloat($(this).val())
			else
				child_target_sum += 0
		parent_total_target = parseFloat($(".parent_due_target_"+parent_user_id).data("total-target"))
		target_due = parent_total_target - child_target_sum
		$(".parent_due_target_"+parent_user_id).html target_due+" Btl"

		return

	$(document).on "change", "#user_target_duration",->
		target_duration = $(this).val()
		if target_duration == 'monthly'
			$("#target_from").hide()
			$("#target_to").hide()
			$("#monthly_target").show()
			$("#MonthPicker_Button_target_month").html("<span class='glyphicon-calendar glyphicon' style='margin-top:8px;'></span>")
		else
			$("#target_from").show()
			$("#target_to").show()
			$("#monthly_target").hide()
		return

	$('.resource_target_amount').on "keyup",->
		target_by = $(this).data('target-by')
		resource_id = $(this).data('resource-id')
		user_target_id = $(this).data('user-target-id')
		target_amount = parseFloat($(this).val())
		resource_name = $(this).data('resource-name')
		resource_target_id = $(this).data('resource-target-id')
		resource_target_sum = 0

		if target_amount <= 0 or isNaN(target_amount)
			Materialize.toast("Please provide some amount", 3000, "red")
			$(".resource-target-list").find("#li_user_resource_#{target_by}_#{resource_id}").remove()
		else
			if $("#li_user_resource_#{target_by}_#{resource_id}").length
				$("#resource_target_amount_span_#{target_by}_#{resource_id}").html target_amount
				$("#resource_target_amount_#{target_by}_#{resource_id}").val target_amount
			else
				contentStr = "<li class='collection-item padding-5' id='li_user_resource_#{target_by}_#{resource_id}'><div>"
				contentStr += "<input type='checkbox' name='checked_user_resources[]' value='#{target_by}_#{resource_id}' id='selected_resource_#{target_by}_#{resource_id}' checked>"
				contentStr += "<label for='selected_resource_#{target_by}_#{resource_id}' class='font-sz-11'>#{resource_name}</label>"
				contentStr += "<span class='secondary-content font-sz-11'><span id='resource_target_amount_span_#{target_by}_#{resource_id}'>#{target_amount}</span></span>"
				contentStr += "<input type='hidden' name='resource_target_amount_#{target_by}_#{resource_id}' value='#{target_amount}' id='resource_target_amount_#{target_by}_#{resource_id}'/>"
				contentStr += "<input type='hidden' name='user_target_id_#{target_by}_#{resource_id}' value='#{user_target_id}' id='user_target_id_#{target_by}_#{resource_id}'/>"
				contentStr += "<input type='hidden' name='resource_target_id_#{target_by}_#{resource_id}' value='#{resource_target_id}' id='resource_target_id_#{target_by}_#{resource_id}'/>"
				contentStr += "</div></li>"
				$(".no-resource-selected").hide()
				$(".resource-target-list").prepend(contentStr)

		$(".resource_target_by_"+target_by).each ->
			if !isNaN(parseFloat($(this).val()))
				resource_target_sum += parseFloat($(this).val())
			else
				resource_target_sum += 0
		total_target = parseFloat($(".parent_due_target_"+target_by).data("total-target"))
		target_due = total_target - resource_target_sum
		$(".parent_due_target_"+target_by).html target_due+" Btl"
		return

	build_form_input = (user_id,product_id,quantity,target_for) ->

		form_element = "<input type='hidden' name='user_products[#{target_for}_id_#{user_id}][][product_id]' value = #{product_id} >"
		form_element += "<input type='number' name='user_products[#{target_for}_id_#{user_id}][][target_quantity]' value = #{quantity} >" 
		return form_element
	validate_if_target_already_added = (user_id,product_id)->
		status = false
		$(".produc_collections").each ->
			if $(this).hasClass("collection_product_#{user_id}_#{product_id}")
				status = true
		return status
	$(document).on "click","#child_user_selection",->
		product_id = $(this).attr("data-product-id")
		selected_product_quantity = parseFloat($("#product_quantity_#{product_id}").val())
		selected_product_target_quantity = parseFloat($(this).attr("data-target-quantity"))
		if selected_product_quantity <= 0 ||  isNaN(selected_product_quantity)
			Materialize.toast("quantity is invalid", 3000, "red")

		else
			if selected_product_quantity>selected_product_target_quantity 
				Materialize.toast("provided quantity id greater than the actual target quantity", 3000, "red")
			else
				product_id = $(this).attr("data-product-id")
				product_name = $(this).attr("data-product-name")
				product_basic_unit = $(this).attr("data-product-basic-unit")
				product_quantity = $("#product_quantity_#{product_id}").val()
				$("#product-info-name").text(product_name)
				$("#product-info-quantity").text(product_quantity)
				$("#product-info-basic-unit").text(product_basic_unit)
				$("#selected-product-id").val(product_id)
				$("#confrim_child_user").attr("data-target-product-quantity",selected_product_target_quantity)
				$("#child-user-modal").modal("show")
		return
	
	$(document).on "click","#confrim_child_user",->
		product_id = $("#selected-product-id").val()
		product_name = $("#product-info-name").text()
		product_quantity = $("#product_quantity_#{product_id}").val()
		product_basic_unit = $("#product-info-basic-unit").text()
		number_of_child_users = $(".selected-child-users").filter(":checked").length
		product_target_quantity = parseFloat($(this).attr("data-target-product-quantity"))
		total_distribution_accross_users = product_quantity*number_of_child_users
		target_for = $(".target_for").val()
		console.log(target_for)
		$("#child-user-modal").modal("hide");

		#if total_distribution_accross_users > product_target_quantity
			#Materialize.toast("total distribution exceeded actual target please adjust the input", 3000, "red")
		#else
		$(".selected-child-users").each ->
			if $(this).prop("checked") == true
				user_id = $(this).val()
				existance_status = validate_if_target_already_added(product_id,user_id)
				if existance_status == false
					html_str = "<div class='collection-item produc_collections padding-5 collection_product_#{product_id}_#{user_id}'>"
					html_str += "<label class='font-sz-11'>#{product_name}</label>"
					html_str += build_form_input(user_id,product_id,product_quantity,target_for)
					html_str += "<label>#{product_basic_unit}</label>"
					html_str += "</div>"
					$("#user_product_list_#{$(this).val()}").append(html_str)
				else
					console.log("already present")
		return	
	$(document).on "click",".expand_cllapse",->
		expand_collapse_id = $(this).attr("data-expandable")
		$("##{expand_collapse_id}").toggleClass('fa-sort-down fa-sort-up');
		return	
	return
