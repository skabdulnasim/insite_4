# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# Cart relatd functionalities
# ###########################
writeCookieData = (name, data) ->
  $.cookie.json = true
  $.cookie name, data, path: "/"
  
readCookieData = (name) ->
  $.cookie.json = true
  $.cookie name  

# Add product to cart
addToCart = ->
  checked_object = $("input[name='items']:checked")
  product_id = checked_object.data "product-id"
  menu_card_id = parseInt $("#menu_card_id").val()
  product = {}
  main_arr = []
  combo_subtotal = 0
  $.each $("input[name='comb_products_of_"+product_id+"']:checked"), ->
    max = $(this).data("max")
    min = $(this).data("min")
    id = $(this).data("comb-id")
    name = $(this).data("name")
    price = $(this).data("comb-price")
    quantity = parseInt $("#qty-"+id).val()
    sub_total = price * quantity
    value = countChecked(product_id,max,min)
    arr = {}
    if value == "true"
      arr =
        menu_product_combination_id : id
        combination_name            : name
        combination_qty             : quantity
        price                       : price
        subtotal                    : sub_total
      main_arr.push arr
      combo_subtotal = combo_subtotal + sub_total
    else
      setAddToCartErrorMsgs 5000,"Please check correct number of combinations"
      return false
    return
  total_quantity = parseInt $("#quantity").val()
  unit_price = checked_object.data "price"
  if isNaN(total_quantity)
    setAddToCartErrorMsgs 5000,"Please provide product quantity."
    return false
  product =
    menu_product_id           : product_id
    name                      : checked_object.data "product-name"
    cost                      : unit_price
    quantity                  : total_quantity
    combo_subtotal            : combo_subtotal
    unit_subtotal             : (unit_price + combo_subtotal)
    image                     : $("#image_url").val()
    preferences               : $("#preferences").val()
    parcel                    : '1'
    order_detail_combinations : main_arr

  if checked_object.length < 1
    setAddToCartErrorMsgs 5000,"Please select a product to add to cart."
    return
  else
    if typeof $.cookie('pos_data') != 'undefined'
      cart_data = readCookieData 'pos_data'
      [is_exist,result] = checkDetails product,menu_card_id
      cart_data['menu_card'][menu_card_id].push product unless is_exist 
      cart_data = result if is_exist
      writeCookieData 'pos_data', cart_data
      show_cart_content menu_card_id
    else
      menuArray = {}
      menuArray[menu_card_id] = new Array(product) 
      cart_data = 
        menu_card : menuArray
      writeCookieData 'pos_data', cart_data
      show_cart_content menu_card_id
    $("#menuModal").modal "hide"
  return

#Show cart content
show_cart_content = (menu_card_id) ->
  data = readCookieData 'pos_data'
  if data == null
    $("#place_pos_order").attr('disabled','disabled')
    $("#cart-products-container").html("<p><small>No products selected.</small></p>")
  else
    $("#place_pos_order").removeAttr('disabled')
    data.cart_data = data['menu_card'][menu_card_id]
    data.menu_card_id = menu_card_id
    result = JST["templates/pos/cart_contents"](data)
    $("#cart-products-container").html result
  return

# Delete item from cart
deleteItem = (id,menu_card_id) ->
  cart_data = readCookieData('pos_data')
  index_to_del = null
  for i in [0..(cart_data['menu_card'][menu_card_id].length-1)]
    if cart_data['menu_card'][menu_card_id][i].menu_product_id == id
      index_to_del = i
  cart_data['menu_card'][menu_card_id].splice(index_to_del,1)
  writeCookieData 'pos_data', cart_data
  show_cart_content menu_card_id
  return

# Display error messages for something bad happens while adding product to cart  
setAddToCartErrorMsgs = (delay_time,msg) ->
  $(".add-to-cart-msgs").fadeIn()
  $(".add-to-cart-msgs").html(msg)
  setTimeout (->
    $(".add-to-cart-msgs").delay(delay_time).fadeOut()
    return
  ), 10
  return

# check wheather proper combinations seleccted or not
countChecked = (ppro_id,max_val,min_val) ->
  n = $( "input[name='comb_products_of_"+ppro_id+"']:checked" ).length
  if n<=max_val && n>=min_val
    return "true"
  else
    return "false"  
  return

# Check product details in cookie  
checkDetails = (product,menu_card_id) ->
  cart_data = readCookieData('pos_data')
  is_exist = false
  
  _.each cart_data['menu_card'][menu_card_id], (data, idx) ->
    if _.isEqual(data, product)
      is_exist = true
      cart_data['menu_card'][menu_card_id][idx].quantity = data.quantity + product.quantity
      return
    return
 
  [is_exist, cart_data]
# Show product details before add to cart
showProductOverlay = (url, image_url, product_id, menu_card_id, currency) ->
  request = $.ajax(
    url: url
    dataType: "json"
  )
  request.done (data, textStatus, jqXHR) ->
    result = undefined
    data.product_details = data
    data.product_image = image_url
    data.menu_card_id = menu_card_id
    data.currency = currency
    $('#menuModal').modal 'show'
    result = JST["templates/pos/customize_product"](data)
    $("#show_product_details").html result
    
    $(".cust_view").hide ""
    $(".add-to-cart-msgs").hide ""
    $(".check_customization").on "change", ->
      id = $(this).data("product-id")
      cust_opt = $(".custom-of-"+id)
      max = cust_opt.data("max")
      min = cust_opt.data("min")
      check_customization_count id,max,min
      if $(this).is ":checked"
        setTimeout (->
          $(".cust_view").fadeOut()
          $(".no_product_selected").fadeOut()
          $("#cust-"+id).delay(500).fadeIn()
          return
        ), 10        
      return

    $(".customizations").on "change", ->
      ppro_id = $(this).data("parent-product-id")
      max = $(this).data("max")
      min = $(this).data("min")
      check_customization_count ppro_id,max,min
      return
  return

check_customization_count = (ppro_id,max,min) ->
  n = $( "input[name='comb_products_of_"+ppro_id+"']:checked" ).length
  if n>max
    $(".custom-warning-msg-"+ppro_id).fadeIn()
    $(".custom-warning-msg-"+ppro_id).html("You can select maximum <span class='label label-warning'>"+max+"</span> items.")
    $("#add-to-cart").attr('disabled','disabled')
  else if n<min
    $(".custom-warning-msg-"+ppro_id).fadeIn()
    $(".custom-warning-msg-"+ppro_id).html("You need to select minimum <span class='label label-danger'>"+min+"</span> item.")
    $("#add-to-cart").attr('disabled','disabled')
  else
    $(".custom-warning-msg-"+ppro_id).fadeOut()
    $("#add-to-cart").removeAttr('disabled')
  return

# Order Related Functionalities
# #############################

# Place new order
place_new_pos_order = (cookie_products_data,menu_id,deliverable_type,deliverable_id,order_unit_id,consumer_type,consumer_id,delivary_date,currency) ->
  $('#posOrderModal').modal 'show'
  $('#posOrderModalStatus').html("Placing new order, please wait")
  $('#posOrderModalBody').html('<i class="fa fa-spinner fa-pulse fa-3x fa-fw margin-bottom"></i>')
  # Placing new order
  request = $.ajax(
    type: 'POST'
    url: "/orders.json"
    dataType: "json"
    data:
      order_status_id:  2
      unit_id:          order_unit_id
      source:           'fos'
      device_id:        'YOTTO05'
      consumer_type:    consumer_type
      consumer_id:      consumer_id
      deliverable_type: deliverable_type
      deliverable_id:   deliverable_id
      delivary_date:    delivary_date
      order_details:    JSON.stringify(cookie_products_data, null) 
  )
  # If order request processed successfully
  request.done (data, textStatus, jqXHR) ->
    if typeof data == 'object' # If something wrong happened
      if data.error
        $('#posOrderModalStatus').html("Error!! #{data.error}.")
      else
        $('#posOrderModalStatus').html("Error!! #{data[0]['error']}.")
      $('#posOrderModalBody').html('')         
      console.log data
    else # If everything ok and order placed
      order_id = data
      $('#posOrderModalStatus').html("Order (ID: #{order_id}) has been successfully placed, bill generation in progress, please wait.")
      # Calculate Bill Details by cross checking every product price
      total_tax = 0
      bill_amount = 0
      tax_details_arr = []
      _.each cookie_products_data, (product, idx) ->
        product_request = $.ajax(
          url:  "/menu_products/#{cookie_products_data[idx].menu_product_id}.json"
          type: "GET"
          dataType: "json"
          async: false
        )
        product_request.done (data, textStatus, jqXHR) ->
          base_price_wot = data["sell_price_without_tax"]
          base_combo_subtotal = 0
          if cookie_products_data[idx].order_detail_combinations.length > 0
            _.each cookie_products_data[idx].order_detail_combinations, (combo, idy) ->
              base_combo_subtotal = base_combo_subtotal + cookie_products_data[idx].order_detail_combinations[idy].subtotal
          base_price_wot = base_price_wot + base_combo_subtotal
          total_base_price_wot = ((cookie_products_data[idx].quantity)*base_price_wot)
          bill_amount = bill_amount + total_base_price_wot
          # Tax calculation
          taxcls_amnt = data["tax_group"]["total_amnt"]
          tax_amnt = (total_base_price_wot * taxcls_amnt / 100)
          total_tax = total_tax + tax_amnt
          # Building Tax details array
          _.each data["tax_group"]["tax_classes"], (t_class, idz) ->
            taxx_amount = parseInt data["tax_group"]["tax_classes"][idz]["ammount"]
            totax_taxx_amount = ((taxx_amount*total_base_price_wot)/100)
            taxd = {}
            taxd =
              tax_class_id : data["tax_group"]["tax_classes"][idz]["id"]
              tax_amount   : totax_taxx_amount
            tax_details_arr.push taxd

      order_ids_a = []
      order_ids_h = {}
      order_ids_h = 
        order_id : order_id
      order_ids_a.push order_ids_h
      # Generating bill
      bill_request = $.ajax(
        type: 'POST'
        url: "/bills.json"
        dataType: "json"
        data:
          order_ids:        JSON.stringify(order_ids_a)
          bill_amount:      bill_amount
          discount:         0
          grand_total:      (bill_amount + total_tax)
          tax_amount:       total_tax
          tax_details:      JSON.stringify(tax_details_arr, null)
          unit_id:          order_unit_id
          user_id:          consumer_id
          deliverable_id:   deliverable_id
          deliverable_type: deliverable_type
      )   
      # If bill request completed successfully
      bill_request.done (data, textStatus, jqXHR) ->
        if data['error'] # If something went wrong
          $('#posOrderModalStatus').html("Error!! #{data[0]['error']}.")
          $('#posOrderModalBody').html('')
          console.log data
        else # Everything went well and bill generated.
          # Fetch order details
          order_details_request = $.ajax(
            type: 'GET'
            url: "/orders/#{order_id}.json"
            dataType: "json"
          )           
          order_details_request.done (order_data, textStatus, jqXHR) ->
            data.order_data = order_data
            $('#posOrderModalStatus').html("Bill generated successfully .")
            data.bill_response = data
            data.cookie_data = cookie_products_data
            data.currency = currency
            data.deliverable_type = deliverable_type
            bill_result = JST["templates/pos/order_details"](data)          
            $("#posOrderModalBody").html bill_result      
      bill_request.error (jqXHR, textStatus, errorThrown) -> 
        $('#posOrderModalStatus').html("Error!! #{errorThrown}.")
        $('#posOrderModalBody').html('')
    return
  request.error (jqXHR, textStatus, errorThrown) ->
    $('#posOrderModalStatus').html("Sorry!! error occured while placing order")
    return
  return

# Window event handlers
# ##############
$(document).ready ->  

  $(".btn-prod-overlay").on "click", ->
    showProductOverlay $(this).data("url"),$(this).data("image-url"),$(this).data("product-id"),$(this).data("menu-card-id"),$(this).data("currency")
    return  

  $("#add-to-cart").on "click", ->
    addToCart()
    return    

  $(".deliverable").on "change", ->
    delivery = $(this).val()
    $("#order_customer_id").val("0") #Restoring customer ID
    $("#order_address_id").val("0") #Restoring address ID
    if delivery == "section"
      $(".customer-mobile").hide()
      $("#customer-container").hide()
      section_request = $.ajax(
        type: 'GET'
        url: "/sections.json"
        dataType: "json"
        data:
          unit_id: $("#unit_id").val()
      )
      section_request.done (data, textStatus, jqXHR) ->
        console.log data
        # data.response = data
        # data.entered_mobile_no = mobile_no
        # result = JST["templates/pos/customer"](data)
        $("#customer-ddressModalBody").html result      
        return
      section_request.error (jqXHR, textStatus, errorThrown) ->
        $("#customer-ddressModalBody").html(errorThrown)
        return      
    else
      $(".customer-mobile").show()
      $("#customer-container").show()
      $("#customer-container").html('')
    return

  $(".mobile-search").on "click", ->
    $('#customer-addressModal').modal 'show'
    $("#customer-ddressModalBody").html("<p class='text-center'>Loading please wait...<p>")
    mobile_no = $("#contact-number").val()
    request = $.ajax(
      type: 'POST'
      url: "/pos_terminals/verify_customer.json"
      dataType: "json"
      data:
        login: mobile_no
    )
    request.done (data, textStatus, jqXHR) ->
      data.response = data
      data.entered_mobile_no = mobile_no
      result = JST["templates/pos/customer"](data)
      $("#customer-ddressModalBody").html result      
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      $("#customer-ddressModalBody").html(errorThrown)
      return       
    return

  #register new customer
  $(document).on "click", "#register-customer",-> 
    request = $.ajax(
      type: 'POST'
      url: "/pos_terminals/register_customer.json"
      dataType: "json"
      data:
        contact_no:       $("#contact_no").val()
        firstname:        $("#address_receiver_first_name").val()
        lastname:         $("#address_receiver_last_name").val()
        pincode:          $("#address_pincode").val()
        delivery_address: $("#delivery_address").val()
        landmark:         $("#address_landmark").val()
        city:             $("#address_city").val()
        state:            $("#address_state").val()
    )
    request.done (data, textStatus, jqXHR) ->
      if data.success
        $('#customer-addressModal').modal 'hide'
        adddress_data = data.address
        $("#order_customer_id").val(adddress_data.customer_id)  #Assigning values to hidden fields
        $("#order_address_id").val(adddress_data.id)  #Assigning values to hidden fields        
        customer_details = "<div class='card card-panel padding-5'><b>#{adddress_data.receiver_first_name} #{adddress_data.receiver_last_name}<small> (#{adddress_data.contact_no})</small></b><small><br>#{adddress_data.delivery_address}, #{adddress_data.landmark}, #{adddress_data.city}-#{adddress_data.pincode}, #{adddress_data.state}<small></div>"
        $("#customer-container").html customer_details      
      else
        if data.error
          $(".user-reg-alert").html data.error           
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      console.log textStatus
      alert "error"
      return    
    return  

  $(document).on "click", "#use-address",->
    cust_id = $(this).data("customer-id")
    address = $('input:radio[name=customer_address]:checked')
    $("#order_customer_id").val(cust_id)
    $("#order_address_id").val(address.val())
    customer_details = "<div class='card card-panel padding-5'><b>#{address.data('address-firstname')} #{address.data('address-lastname')}<small> (#{address.data('address-contact')})</small></b><small><br>#{address.data('delivery-address')}, #{address.data('address-landmark')}, #{address.data('address-city')}-#{address.data('address-pincode')}, #{address.data('address-state')}<small></div>"
    $("#customer-container").html customer_details    
    $('#customer-addressModal').modal 'hide'
    $(".customer-mobile").hide()
    return       

  #Delete item from cart
  $(document).on "click", ".btn_delete",->
    id = $(this).data("id")
    menu_id = $(this).data("menu-card-id")
    $("#row_"+id).hide ""
    deleteItem id,menu_id
    return 

  #Event for place order
  $(document).on "click", "#place_pos_order",->
    deliverable = $('input:radio[name=deliverable]:checked').val()
    menu_card_id = parseInt $("#menu_card_id").val()
    unit_id = $(this).data("unit-id")
    consumer_type = $(this).data("consumer-type")
    consumer_id = $(this).data("consumer-id")    
    delivary_date = $(this).data("delivery-date")    
    currency = $(this).data("currency")    
    cart_data = readCookieData 'pos_data'    
    if cart_data && cart_data['menu_card'][menu_card_id].length > 0
      cust_id = $("#order_customer_id").val()
      if deliverable == "address" # Home delivery orders
        addr_id = $("#order_address_id").val()  
        if cust_id > 0 && addr_id > 0
          place_new_pos_order cart_data['menu_card'][menu_card_id],menu_card_id,deliverable,addr_id,unit_id,consumer_type,consumer_id,delivary_date,currency
        else
          $(".customer-mobile").show()
          $("#customer-container").html("<div class='alert m-alert-danger padding-5'>Customer or address not found.</div>")        
      else if deliverable == "section" # Inhouse orders
        section_id = 1
        place_new_pos_order cart_data['menu_card'][menu_card_id],menu_card_id,deliverable,section_id,unit_id,consumer_type,consumer_id,delivary_date,currency
      else
        alert "Ordering option for this deliverable type is not available yet"
    else
      $("#cart-products-container").html("<div class='alert m-alert-danger padding-5'>Please select some items from left to place new order.</div>")
    return     