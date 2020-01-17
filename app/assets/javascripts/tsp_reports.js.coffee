# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  # Loctaion show on visiting history  

  geocodeLatLng = (geocoder, map, infowindow, marker, latilongi, resource_name, air_distance) ->
    input = latilongi
    latlngStr = input.split(',', 2)
    latlng = 
      lat: parseFloat(latlngStr[0])
      lng: parseFloat(latlngStr[1])
    geocoder.geocode { 'location': latlng }, (results, status) ->
      if status == 'OK'
        if results[0]
          contentString = "<div class='info-window'>" +
                "<h3>"+resource_name+"</h3>" +
                "<div class='info-content'>" +
                "<div><p><i class='fa fa-map-marker'></i> &nbsp;"+results[0].formatted_address+"</p></div>" +
                "<div><p><i class='fa fa-road'></i> &nbsp;"+air_distance+"</p></div>" +
                "</div>" +
                "</div>";
          infowindow.setContent contentString
          infowindow.open map, marker
        else
          'No address found'
      else
        'Geocoder failed due to: ' + status
    return

  distance = (lat1, lon1, lat2, lon2) ->
    R = 6371
    # km (change this constant to get miles)
    dLat = (lat2 - lat1) * Math.PI / 180
    dLon = (lon2 - lon1) * Math.PI / 180
    a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * Math.sin(dLon / 2) * Math.sin(dLon / 2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    d = R * c
    if d > 1
      return Math.round(d) + 'km'
    else if d <= 1
      return Math.round(d * 1000) + 'm'
    d
  
  $overlay = $('.overlay')
  resize = true
  map = undefined
  
  $(document).on "click", ".map-view", -> 
    clat = $(this).data("clat")
    clon = $(this).data("clon")
    visited_data = $(this).data("latlon")
    cname = $(this).data("cname")
    cphone = $(this).data("cphone")
    if clat != '' and clon != ''
      initialize = ->
      mapOptions = 
        zoom: 8
        center: new (google.maps.LatLng)(clat, clon)
        mapTypeId: google.maps.MapTypeId.ROADMAP
    else
      initialize = ->
      mapOptions = 
        zoom: 8
        center: new (google.maps.LatLng)(visited_data[0].lat, visited_data[0].lon)
        mapTypeId: google.maps.MapTypeId.ROADMAP
    map = new (google.maps.Map)(document.getElementById('map-canvas'), mapOptions)
    geocoder = new (google.maps.Geocoder)

    if clat != '' and clon != ''
      myLatlng_c = new google.maps.LatLng(clat, clon)
      marker_c = new (google.maps.Marker)(
        position: myLatlng_c
        title: cname
        icon: '/assets/icons/ic_marker_salesboy.svg'
      )
      marker_c.setMap(map) 
      infowindow_c = new google.maps.InfoWindow()
      cinfo="<div style='overflow: auto;'><div><i class='fa fa-user'></i> &nbsp;"+cname+"</div><div><i class='fa fa-phone'></i> &nbsp;"+cphone+"</div></div>"
      marker_c.addListener 'click', ->
        infowindow_c.open map, marker_c
        infowindow_c.setContent cinfo
        return 

    for key of visited_data

      # CODING BY ABDUL 
      if visited_data[key].customer_address != undefined
        geocoder.geocode { 'address': visited_data[key].customer_address }, (results, status) ->
          if status == google.maps.GeocoderStatus.OK
            latitude = results[0].geometry.location.lat()
            longitude = results[0].geometry.location.lng()

            myLatlng_customer = new google.maps.LatLng(latitude, longitude)
            marker_customer = new (google.maps.Marker)(
              position: myLatlng_customer
              title: visited_data[key].resource_name
              icon: '/assets/icons/cus_map_marker.svg'
            )
            marker_customer.setMap(map) 
            infowindow_customer = new google.maps.InfoWindow()
            google.maps.event.addListener marker_customer, 'click', do (marker, key) ->
              ->
                air_distance_customer=undefined
                air_distance_customer = distance(clat, clon, latitude, longitude)
                latilongi_customer = latitude+','+ longitude
                geocodeLatLng(geocoder, map, infowindow_customer, marker_customer, latilongi_customer, visited_data[key].resource_name, air_distance_customer)
                return
          return

      # CODING BY ABDUL
     
      myLatlng = new google.maps.LatLng(visited_data[key].lat, visited_data[key].lon)
      marker = new (google.maps.Marker)(
        position: myLatlng
        title: visited_data[key].resource_name
      )
      marker.setMap(map) 
      infowindow = new google.maps.InfoWindow()
      google.maps.event.addListener marker, 'click', do (marker, key) ->
        ->
          air_distance=undefined
          air_distance = distance(clat, clon, visited_data[key].lat, visited_data[key].lon)
          latilongi = visited_data[key].lat+','+visited_data[key].lon
          geocodeLatLng(geocoder, map, infowindow, marker, latilongi, visited_data[key].resource_name, air_distance)
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
    
  $(document).on "change", ".user-list",->
    $(".tse-name").val('')
    from_date = $("#from_date").val()
    to_date = $("#to_date").val()
    user_id = $(".user-list").val()
    href = "/tsp_reports/by_date_range.csv?&from_date=#{from_date}&to_date=#{to_date}&user_id=#{user_id}"
    $(".export-visiting-report").prop('href', href);
    return
  # method to build the URL to download CSV for day_by_day_order_reports
  prepare_url_for_day_by_day_order_reports_csv = (user_id,filter_type,name_like) ->
    from_date = $("#from_date").val()
    to_date = $("#to_date").val()
    href = "/tsp_reports/day_by_day_order_reports.csv?&from_date=#{from_date}&to_date=#{to_date}&user_id=#{user_id}&report_type_filteration=#{filter_type}&tse_filter=#{name_like}"
    $(".unit_ids").each ->
      href = href+"&unit_ids[]="+$(this).val()
      return
    $(".export-orders-report").prop('href', href);
    console.log(href)
    return
  # for day_by_day_order_report tsp list filter
  $(document).on "change", ".tsp-list",->
    $(".search-tse").val('')
    user_id = $(".tsp-list").val()
    filter_type = $(".filter_type").val()
    prepare_url_for_day_by_day_order_reports_csv(user_id,filter_type,"")
    return  
  # for day_by_day_order_report search by name filter
  $(document).on "change keyup", ".search-tse",->
    $(".tsp-list").removeAttr("selected")
    $(".tsp-list").val($(".tsp-list option:first").val());
    filter_type = $(".filter_type").val()
    search_text = $(this).val()
    prepare_url_for_day_by_day_order_reports_csv("",filter_type,search_text)
    return
  # for day_by_day_order_report report type filter
  $(document).on "change", "#report_type_filteration", ->
    filter_type = $(this).val()
    user_id = $(".tsp-list").val()
    search_text = $(".search-tse").val()
    prepare_url_for_day_by_day_order_reports_csv(user_id,filter_type,search_text)
    return

  $(document).on "change", ".shop-list",->
    from_date = $("#from_date").val()
    to_date = $("#to_date").val()
    resource_id = $(".shop-list").val()
    href = "/tsp_reports/day_by_day_shop_order_report.csv?&from_date=#{from_date}&to_date=#{to_date}&resource_id=#{resource_id}"
    $(".export-shop-orders-report").prop('href', href);
    return 

        
  $(document).on "change", ".resource-list",->
    from_date = $("#from_date").val()
    to_date = $("#to_date").val()
    resource_id = $(".resource-list").val()
    report_mode = $(".report-mode-list").val()
    href = "/tsp_reports/day_by_day_shop_order_report.csv?&from_date=#{from_date}&to_date=#{to_date}&resource_id=#{resource_id}&report_mode=#{report_mode}"
    $(".export-shop-orders-group-report").prop('href', href);
    return 

  $(document).on "keyup", ".search-resource-sumary",->
    from_date = $("#from_date").val()
    to_date = $("#to_date").val()
    report_mode = $(".report-mode-list").val()
    search_text = $(this).val()
    href = "/tsp_reports/day_by_day_shop_order_report.csv?&from_date=#{from_date}&to_date=#{to_date}&resource_filter=#{search_text}&report_mode=#{report_mode}"
    $(".export-shop-orders-group-report").prop('href', href);
    return   
    
  $(document).on "change", ".report-mode-list",->
    from_date = $("#from_date").val()
    to_date = $("#to_date").val()
    resource_id = $(".resource-list").val()
    report_mode = $(".report-mode-list").val()
    href = "/tsp_reports/day_by_day_shop_order_report.csv?&from_date=#{from_date}&to_date=#{to_date}&resource_id=#{resource_id}"
    $(".export-shop-orders-group-report").prop('href', href);
    return 

  $(document).on "change keyup", ".tse-name",->
    $(".user-list").removeAttr("selected")
    $(".user-list").val($(".user-list option:first").val());
    from_date = $("#from_date").val()
    to_date = $("#to_date").val()
    search_text = $(this).val()
    href = "/tsp_reports/by_date_range.csv?&from_date=#{from_date}&to_date=#{to_date}&tse_filter=#{search_text}"
    $(".export-visiting-report").prop('href', href);
    return  



  $(document).on "keyup", ".resource-name",->
    #$(".tsp-list").removeAttr("selected")
    #$(".tsp-list").val($(".tsp-list option:first").val());
    search_text = $(this).val()
    href = "/tsp_reports/shop_sumary_report.csv?&resource_filter=#{search_text}"
    $(".export-shop-sumary-report").prop('href', href);
    return 

  $(document).on "keyup", ".tse-list",->
    from_date = $("#from_date").val()
    to_date = $("#to_date").val()
    search_text = $(this).val()
    href = "/tsp_reports/tse_sumary_report.csv?&from_date=#{from_date}&to_date=#{to_date}&tse_filter=#{search_text}"
    $(".export-tse-sumary-report").prop('href', href);
    return 

  $(document).on "keyup", ".search-resource",->
    from_date = $("#from_date").val()
    to_date = $("#to_date").val()
    search_text = $(this).val()
    href = "/tsp_reports/day_by_day_shop_order_report.csv?&from_date=#{from_date}&to_date=#{to_date}&resource_filter=#{search_text}"
    $(".export-day-by-day-shop-order-report").prop('href', href);
    return  
   
  $(document).on "keyup", ".shop-database",->
    search_text = $(this).val()
    href = "/tsp_reports/shop_database.csv?&resource_filter=#{search_text}"
    $(".export-shop-database-report").prop('href', href);
    return      
  $(document).on "keyup change", ".tse-filter, .store-list",->
    tse_filter = $(".tse-filter").val()
    store_id = $(".store-list").val()
    console.log(tse_filter)
    href = $(".export-tse-sales-report").attr('href')
    href=href+"&tse_filter=#{tse_filter}&store_id=#{store_id}"
    $(".export-tse-sales-report").prop('href',href)
    return
  $(document).on "change",".store_id_for_shop_sales",->
    strore_id = $(this).val()
    url = $(".export-shop-sales-report").prop('href')
    url = url+"&store_id=#{strore_id}"
    console.log(url)
    $(".export-shop-sales-report").prop('href',url)
    return
  $(document).on "change",".store_id_for_plant_sales",->
    strore_id = $(this).val()
    url = $(".export-plant-wise-dispatch-report").prop('href')
    url = url+"&store_id=#{strore_id}"
    $(".export-plant-wise-dispatch-report").prop('href',url)
    return
  $(document).on "change",".store_id_for_district_wise_sales",->
    store_id = $(this).val()
    url = $(".export-district-wise-sales-report").prop('href')
    url = url+"&store_id=#{store_id}"
    $(".export-district-wise-sales-report").prop('href',url)
    return