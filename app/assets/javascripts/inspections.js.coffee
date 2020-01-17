# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->

	$(document).on "click", ".fancybox", (e) ->
		inspection_question_id = $(this).data('inspection-question-id')
		$(".fancybox_#{inspection_question_id}").fancybox
			openEffect: 'none'
			closeEffect: 'none'
		e.preventDefault()
	
	# $(document).on "click", ".show_more", ->
	# 	$('.fancybox').click()
	# 	return	
	
	$(document).on "click", ".inspection_row", ->
		user_inspection_latitude = $(this).data('user-inspection-lat')
		user_inspection_longitude = $(this).data('user-inspection-long')
		resource_latitude = $(this).data('resource-lat')
		resource_longitude = $(this).data('resource-long')
		salesman_latitude = $(this).data('salesman-lat')
		salesman_longitude = $(this).data('salesman-long')
		inspection_id = $(this).data('inspection-id')
		salesman_address = $(this).data('salesman-address')
		resource_address = $(this).data('resource-address')
		resource_name = $(this).data('resource-name')
		salesman_name = $(this).data('salesman-name')
		user_inspection_discussion = $(this).data('user-inspection-discussion')
		lat_long_array = []


		request = $.ajax(
			type: 'GET'
			url: "/api/v2/inspections/#{inspection_id}"
			dataType: "json"
		) 
		request.done (responseData, textStatus, jqXHR) ->
			data = responseData.data
			if data.inspection_questions.length > 0
				data.response = data
				result = JST["templates/inspections/question_answer_details"](data)
				$("#inspection_ques_#{inspection_id}").html result
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			Materialize.toast("AJAX Error", 5000)
			return
	
		if typeof(user_inspection_latitude) != 'undefined' && typeof(user_inspection_longitude) != 'undefined'
			user_inspection_lat_long_array =
			{
				"lat": user_inspection_latitude,
				"lng": user_inspection_longitude,
				"picture": {
					"url": "/assets/icons/inspection.svg",
					"width":  45,
					"height": 45
				},
				"infowindow": "#{user_inspection_discussion}"
			}
			lat_long_array.push user_inspection_lat_long_array

		resource_infowindow = "<div class='float-l'><i class='fa fa-bank'></i> &nbsp#{resource_name}</div><br/><br/><div class='float-l'><i class='fa fa-map-marker'></i> &nbsp#{resource_address}</div>"
		if typeof(resource_latitude) != 'undefined' && typeof(resource_longitude) != 'undefined'
			resource_lat_long_array =
			{
				"lat": resource_latitude,
				"lng": resource_longitude,
				"picture": {
					"url": "/assets/icons/ic_marker_subStore.svg",
					"width":  45,
					"height": 45
				},
			"infowindow": "#{resource_infowindow}"
			}
			lat_long_array.push resource_lat_long_array

		salesman_infowindow = "<div class='float-l'><i class='fa fa-user'></i> &nbsp#{salesman_name}</div><br/><br/><div class='float-l'><i class='fa fa-map-marker'></i> &nbsp#{salesman_address}</div>"
		if typeof(salesman_latitude) != 'undefined' && typeof(salesman_longitude) != 'undefined'
			salesman_lat_long_array =
			{
				"lat": salesman_latitude,
				"lng": salesman_longitude,
				"picture": {
					"url": "/assets/icons/ic_marker_salesboy.svg",
					"width":  45,
					"height": 45
				},
				"infowindow": "#{salesman_infowindow}"
			}
			lat_long_array.push salesman_lat_long_array

		handler = Gmaps.build 'Google'
		handler.buildMap { provider: {}, internal: {id: "inspections_map_#{inspection_id}"} }, ->
			# markers = handler.addMarkers([lat_long_array])
			for k in [0..(lat_long_array.length - 1)]
				markers = handler.addMarkers([
					lat_long_array[k]
				])
			handler.bounds.extendWith(markers)
			handler.fitMapToBounds()
			handler.getMap().setZoom(9)

		return
	
	return