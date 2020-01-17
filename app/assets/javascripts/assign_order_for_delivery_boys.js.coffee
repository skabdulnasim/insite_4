#Document Ready Event
$(document).ready -> 
  ###call_map_view =  ->
    google.maps.event.addDomListener window, 'load', initialize
    return###
  if ($.cookie('orders_to_db')?)
    $.removeCookie('orders_to_db')
  #Submit Value to Assign Order
  $('#submit_assign_order').click ->
   
    if !$("input[name='delivery_boy_id']:checked").val()?
      alert 'Please Select Exact Options!'
      return false
    orders_to_db = $.cookie('orders_to_db')

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

  #Ajax Success Function of Cancel Assigned Orders    
  success_on_cancel_order =  ->  
    initialize()
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