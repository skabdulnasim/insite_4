# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
	$(document).on "click", ".resource_order", ->
		
		resource_latitude = $(this).data('resource-lat')
		resource_longitude = $(this).data('resource-long')
		console.log "#{resource_latitude} and #{resource_longitude}"
		resource_name ="resource"
		resource_order_id = $(this).data("resource_order-id")
		lat_long_array = []
	
		if typeof(resource_latitude) != 'undefined' && typeof(resource_longitude) != 'undefined'
			resource_infowindow = "<div class='float-l'><i class='fa fa-bank'></i> &nbsp#{resource_name}</div><br/><br/><div class='float-l'><i class='fa fa-map-marker'></i></div>"
			if typeof(resource_latitude) != 'undefined' && typeof(resource_longitude) != 'undefined'
				resource_lat_long_array =
				{
					"lat": resource_latitude,
					"lng": resource_longitude,
					"picture": {
						"url": "/assets/icons/ic_marker_subStore.svg",
						"width":  45,
						"height": 45
					}
				}
				lat_long_array.push resource_lat_long_array

			handler = Gmaps.build 'Google'
			console.log lat_long_array
			handler.buildMap { provider: {}, internal: {id: "resource_order_#{resource_order_id}"} }, ->
				# markers = handler.addMarkers([lat_long_array])
				for k in [0..(lat_long_array.length - 1)]
					markers = handler.addMarkers([
						lat_long_array[k]
					])
				handler.bounds.extendWith(markers)
				handler.fitMapToBounds()
				handler.getMap().setZoom(7)
		return
	return