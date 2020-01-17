#Document Ready Event
$(document).ready -> 
  ###call_map_view =  ->
    google.maps.event.addDomListener window, 'load', initialize
    return###
  if ($.cookie('orders_to_db')?)
    $.removeCookie('orders_to_db')
  if ($.cookie('returns_to_db')?)
    $.removeCookie('returns_to_db')
#Submit Value to Assign Order
  $('#submit_assign_order').click ->
   
    if !$("input[name='delivery_boy_id']:checked").val()?
      alert 'Please Select Exact Options!'
      return false
    orders_to_db = $.cookie('orders_to_db')
    returns_to_db = $.cookie('returns_to_db')

    request = $.ajax(
        type      : 'POST'
        dataType  : 'json'
        accepts   : {text : 'application/json; charset=utf-8'}
        url       : "/delivery_boys/create_assign_order?data=#{orders_to_db}"
      )

    request.done (data, textStatus, jqXHR) ->
      if data["success"] != null
        success_on_submit()    
    return
#Ajax Success Function of Submit Assign Order
  success_on_submit =  ->
    #initialize()
    $("ul#orders_ul").each ->
      $(this).empty()
      return
    $("span.cout_order").each ->
      $(this).html(0)
      return 
    delivery_boy_id = $("input[name='delivery_boy_id']:checked").val()
    orders_to_db = JSON.parse $.cookie('orders_to_db')  
    
    for value, index in orders_to_db[delivery_boy_id]
      $('#'+value ).remove()
    $.removeCookie('orders_to_db')   
    $(".alert").show()
    setTimeout (->
      $('.alert').fadeOut 1500
      return
    ), 5000

#Calcel Assigned Order
  $('#cancel_assigned_order').click ->
    orders_to_db = $.cookie('orders_to_db')
    request = $.ajax(
        type      : 'POST'
        dataType  : 'json'
        accepts   : {text : 'application/json; charset=utf-8'}
        url       : "/delivery_boys/cancel_assigned_order/#{orders_to_db}"
      )

    request.done (data, textStatus, jqXHR) ->
      if data["success"] != null
        success_on_cancel_order()      
    return
#Ajax Success Function of Cancel Assigned Orders    
  success_on_cancel_order =  ->  
    #initialize()
    orders_to_db = JSON.parse $.cookie('orders_to_db')  
    
    for k of orders_to_db
      obj_array = orders_to_db[k]
      obj_array.forEach (item) ->
        $('#'+item ).remove()
        
    $.removeCookie('orders_to_db')   
    $(".alert").show()
    setTimeout (->
      $('.alert').fadeOut 1500
      return
    ), 5000 
$(document).on 'mouseenter','.order-summery', ->
  ref_element = $(this)
  order_id = $(this).data('orderid')
  
  if ($.cookie('orders')?)
    orders = JSON.parse $.cookie('orders') 
  else
    orders = {}
  
  if orders.hasOwnProperty order_id
    display_order_info_window(ref_element,orders,order_id)
    #console.log "here"

  else  
    status = $(this).data('orderstatus')
    request = $.ajax(
        type      : 'GET'
        dataType  : 'json'
        accepts   : {text : 'application/json; charset=utf-8'}
        url       : "/orders/#{order_id}"
      )

    request.done (data, textStatus, jqXHR) ->
      temp = (element.menu_product.product for element in data.order_details)
      orders[order_id] = 
        products : temp
        status   : status
      #console.log orders[order_id] 
      display_order_info_window(ref_element,orders,order_id) 
      $.cookie('orders',JSON.stringify orders)

  
  


$(document).on 'mouseleave','.order-summery', ->
   $('.item-details').html ""
   $('.arrow_left').css display: 'none'
   $('.arrow_right').css display: 'none'
   $('.item-details-container').toggle()

   

check_val_in_obj = (obj, val) ->
  temp = ''
  for k of obj
    obj_array = obj[k]
    obj_array.forEach (item) ->
      if parseInt(item) == parseInt(val)
        temp = k
  return temp    
  return

$(document).on 'click',"input[name='order_ids[]']", (event)->
  page_action = location.pathname.split('/').slice(-1)[0]
  if page_action != 'assign_order'
    delivery_boy_id = $('#delivery_boy_id').val()

  if ($.cookie('orders_to_db')?)
    orders_to_db = JSON.parse $.cookie('orders_to_db') 
  else
    orders_to_db = {}

  delivery_boy_id = $("input[name='delivery_boy_id']:checked")

  if delivery_boy_id.length > 0
    exist_db_id = check_val_in_obj(orders_to_db,$(this).val())
    
    if (!orders_to_db[delivery_boy_id.val()]?)
      orders_to_db[delivery_boy_id.val()] = []

    if this.checked

      if exist_db_id != ""
        delete_val_from_array(orders_to_db[exist_db_id], exist_db_id, $(this).val(), page_action)
        push_val_to_array(orders_to_db[delivery_boy_id.val()], delivery_boy_id.val(), $(this), page_action)
      else 
        push_val_to_array(orders_to_db[delivery_boy_id.val()], delivery_boy_id.val(), $(this), page_action)
    else
      if exist_db_id != ""
        delete_val_from_array(orders_to_db[exist_db_id], exist_db_id, $(this).val(), page_action)
      else  
        delete_val_from_array(orders_to_db[delivery_boy_id.val()], delivery_boy_id.val(), $(this).val(), page_action)  

    $.cookie('orders_to_db',JSON.stringify orders_to_db) 
    
  else
    if page_action == 'assign_order'
      alert "Please select a delivery boy boy"
      event.preventDefault()
      event.stopPropagation()
      return false
    else
      if (!orders_to_db[delivery_boy_id]?)
        orders_to_db[delivery_boy_id] = []
      if this.checked
        push_val_to_array(orders_to_db[delivery_boy_id], delivery_boy_id, $(this), page_action)
      else 
        delete_val_from_array(orders_to_db[delivery_boy_id], delivery_boy_id, $(this).val(), page_action)
      $.cookie('orders_to_db',JSON.stringify orders_to_db)

  orders_to_db = JSON.parse($.cookie('orders_to_db'))
  console.log orders_to_db
#Check Value is Exist In Object
check_val_in_obj = (obj, val) ->
  temp = ''
  for k of obj
    obj_array = obj[k]
    obj_array.forEach (item) ->
      if parseInt(item) == parseInt(val)
        temp = k
  return temp  
#Delete Value from Array
delete_val_from_array = (obj, index, val, page_action) ->  
  obj.splice( $.inArray(val,obj) ,1 )
  if page_action == 'assign_order'
    $('li:contains('+val+')').remove()
    $('#assigned_order_count'+index).html(parseInt($('#assigned_order_count'+index).html())-1)
  return
#Push Value to Array
push_val_to_array = (obj, index, thisObj, page_action) -> 
  val            = thisObj.val()
  delivarydate   = thisObj.data("delivarydate")
  html_data      = 'OrderID: #'+val+'  <i class="fa fa-clock-o"></i> ' +delivarydate
  obj.push val
  if page_action == 'assign_order'
    $('<li/>', {html: html_data}).addClass('order-summery list-group-item').attr('data-orderid', val).appendTo('ul.assigned_orders'+index)
    $('#assigned_order_count'+index).html(parseInt($('#assigned_order_count'+index).html())+1)
  return 


                                #MAP Implementation

#User Defined Functions
window.initialize = ->
  mapOptions =
    center:
      lat: 0
      lng: 0
    zoom: 14
    mapTypeId: 'roadmap'

  map = new (google.maps.Map)(document.getElementById('map_canvas'), mapOptions)
  map.setTilt 45
  setMarker map
#End of initialize    

setMarker =(mapObj) ->
  #Initialize Ajax call
  request = $.ajax(
      type      : 'GET'
      dataType  : 'json'
      accepts   : {text : 'application/json; charset=utf-8'}
      url       : '/delivery_boys/fetch_order_data'
    )
  
  #Success Callback of Ajax Call
  request.done (data, textStatus, jqXHR) ->
    
    setSourceMarker data.source, mapObj
    
    setDestinationMarker data.destinations, mapObj
   

  #Failure Callback of Ajax Call
  request.fail (jqXHR,textStatus,errorThrown) ->
    return
#End of setMarker


setSourceMarker = (sourceData, mapObj) ->
  #Marker For Source
  mapObj.setCenter(new google.maps.LatLng(sourceData.marker_info[0],sourceData.marker_info[1]))

  template_result = JST["templates/delivery_boys/outlet_info"](sourceData)
  infowindow = new (google.maps.InfoWindow)(content: template_result)

  marker = new (google.maps.Marker)(
      position  : new google.maps.LatLng(sourceData.marker_info[0],sourceData.marker_info[1])
      icon      : '/uploads/markers/shop.png'
  )
  
  google.maps.event.addListener marker, 'click', ->
    infowindow.open mapObj, this
    return
  
  marker.setMap mapObj


setDestinationMarker = (destinationsData, mapObj) ->
  #Marker For Destinations
  infowindow = new google.maps.InfoWindow
  
  for element in destinationsData
    template_result = JST["templates/delivery_boys/order_info"](element.order_info)
    
    marker = new (google.maps.Marker)(
      map       : mapObj
      position  : new google.maps.LatLng(element.marker_info[0],element.marker_info[1])
      icon      : '/uploads/markers/package_32_white.png'
      info      : template_result
    )
    
    google.maps.event.addListener marker, 'click', ->
      infowindow.setContent this.info
      infowindow.open mapObj, this
      if ($.cookie('orders_to_db')?)
        check_if_order_already_assigned($.cookie('orders_to_db'))
      return


#Check Order is Already Assigned
check_if_order_already_assigned = (obj) ->  
  orders_to_db = JSON.parse obj 
        
  $("input[type='checkbox'][name='order_ids[]']").each ->
    value = $(this).attr('value')
    already_exist = check_val_in_obj(orders_to_db,value)
    if already_exist != ''
      $(this).attr('checked', 'checked')
    return
  return  
  #end of Loop

display_order_info_window = (ref_element,orders,order_id) ->
  offset =  ref_element.offset()
  view   =  ref_element.data("view")
  topPosition = "#{offset.top - $(window).scrollTop()}px"
  
  if view == "marker_info"
    leftPosition  = "#{offset.left+ref_element.width()+5}px"
    rightPosition = ""
    $('.arrow_left').css display: 'block'
  else
    leftPosition  = ""
    rightPosition = "28%"
    $('.arrow_right').css display: 'block'
    
 
  template_result = JST["templates/delivery_boys/order_details"](orders[order_id])
  $('.item-details').html template_result
  $('.item-details-container').toggle()
  $('.item-details-container').css
    position: 'fixed'
    top: topPosition
    left: leftPosition
    right: rightPosition

$(document).on 'click',"#cancel_assigned_return", (event)->
  if $('.return-ids:checkbox:checked').length < 1
    Materialize.toast("Select Return Order First", 3000, 'red')
  else
    return_array = []
    $('.return-ids:checkbox:checked').map ->
      return_id = $(this).val()
      return_array.push return_id
    request = $.ajax(
      type: 'POST'
      url: "/delivery_boys/cancel_assigned_return/"
      data:
        return_ids: return_array
    )
    request.done (data, textStatus, jqXHR) ->
      if data["success"] != null
        $('.return-ids:checkbox:checked').map ->
          return_id = $(this).val()
          $("#return_id_#{return_id}").parent('td').parent('tr').remove()
        Materialize.toast("#{data['success']}", 3000 , 'green')
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "Error"
      return
  return

$(document).on 'click',"#order_tab", (event)->
  if !$(this).parent('li').hasClass('active')
    if $('.return-ids:checkbox:checked').length > 0
      if !window.confirm('All checkboxes will be unchecked')
        return false
      $('.return-ids').prop("checked", false)
      $('#parent_check').prop("checked", false)
  return

$(document).on 'click',"#return_tab", (event)->
  if !$(this).parent('li').hasClass('active')
    if $('.order-ids:checkbox:checked').length > 0
      if !window.confirm('All checkboxes will be unchecked')
        return false
      $.removeCookie('orders_to_db')
      $('.order-ids').prop("checked", false)
  return

# table_view_order
# order_tab
# table_view_return
# return_tab

