# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
	$overlay = $('.overlay')
	resize = true
	map = undefined
	
	$(document).on "click", ".map-view", -> 
		lat = $(this).data("lat")
		lon = $(this).data("lon")
		lat_v = $(this).data("lat-v")
		lon_v = $(this).data("lon-v")
		contentString = $(this).data("text")
		contentString_v = $(this).data("text-v")
		initialize = ->
		mapOptions = 
			zoom: 5
			center: new (google.maps.LatLng)(lat, lon)
			mapTypeId: google.maps.MapTypeId.ROADMAP
		myLatlng = new google.maps.LatLng(lat,lon)
		myLatlng_v = new google.maps.LatLng(lat_v,lon_v)
		map = new (google.maps.Map)(document.getElementById('map-canvas'), mapOptions)
		for i in [0..1]
			if i==0
				marker = new (google.maps.Marker)(
					position: myLatlng
					title: contentString
				)
				marker.setMap(map)
				infowindow = new (google.maps.InfoWindow)(content: contentString)
				marker.addListener 'click', ->
					infowindow.open map, marker
					return
			if i==1
				marker_v = new (google.maps.Marker)(
					position: myLatlng_v
					title: contentString_v
				)
				marker_v.setMap(map)
				infowindow_v = new (google.maps.InfoWindow)(content: contentString_v)
				marker_v.addListener 'click', ->
					infowindow_v.open map, marker_v
					return        
		google.maps.event.addDomListener window, 'load', initialize
		$overlay.show()
		if resize
			google.maps.event.trigger map, 'resize'
			resize = false
		return
	$('.overlay-bg').click ->
		$overlay.hide()
		return 

# Change status approve or reject
	$(document).on "click", ".update_status", ->
		vpp_id = $(this).data('vpp-id')
		status = $(this).data('status')
		request = $.ajax(
			type: 'POST'
			url: '/vendor_product_prices/update_status'
			data:
				vpp_id: vpp_id
				status: status
		)
		request.done (data, textStatus, jqXHR) ->
			Materialize.toast("Vendor #{data.status}", 5000)
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			alert "Error"
			return
		return