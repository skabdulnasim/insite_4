$(document).ready ->
  destination_units = []
  $(document).on "click keyup", ".on_behalf_smart_po_checkbox",->    
    
    product_id = $(this).data("product-id")
    $(".estimated_cost_#{product_id}").prop("disabled", false)
    item_price = $(".price_#{product_id}").val()
    vendor_product_id = $(this).data("vendor-product-id")
    item_quantity = parseFloat($(".transfer-quantity-#{product_id}").val())
    unit_input = $(".unit-input-#{product_id}").val()
    unit_input = unit_input.split("__")
    item_name = $(this).data("product-name")
    item_unit = $(this).data("basic-unit")
    multiplier = parseFloat(unit_input[2])
    multiplier = 1 if isNaN(multiplier)
    estimated_price = (item_price*item_quantity*multiplier).toFixed(2)
    business_type = $(this).data("business-type")

    if unit_input[0] > 0
      item_unit_id = unit_input[0]
      item_unit = unit_input[1]
    else
      item_unit_id = 0
      item_unit = $(this).data("basic-unit")

    $(".estimated_cost_#{product_id}").val estimated_price
    $(".po_color_size_#{product_id}").val(0)
    $("#p_total_qty_#{product_id}").val(0)
    if $(".li_color_size_product_#{product_id}").length
      $(".li_color_size_product_#{product_id}").remove()

    if ($(".po_checkbox_#{product_id}").is ":checked")
      if item_quantity < 0 or isNaN(item_quantity)
        Materialize.toast("Please provide some quantity of #{item_name}.", 3000)
        $(".po-product-list").find("#li_product_#{product_id}").remove()
      else
        $(".po_checkbox_#{product_id}").removeClass 'error-input red'
        if $("#cart_item_#{product_id}").length
          $("#cart_item_#{product_id}").val item_quantity
          $("#item_qty_#{product_id}").html item_quantity
          $("#cart_item_unit_#{product_id}").val item_unit_id
          $("#item_unit_#{product_id}").html item_unit
          $("#cart_item_price_#{product_id}").val item_price
        else
          contentStr = "<li class='collection-item' id='li_product_#{product_id}'><div>"
          contentStr += "<input type='checkbox' name='checked_raw[]' value='#{product_id}' id='product_#{product_id}' checked>"
          contentStr += "<label for='product_#{product_id}' class='font-sz-11'>#{item_name}</label>"
          contentStr += "<span class='secondary-content font-sz-11'><span id='item_qty_#{product_id}'>#{item_quantity}</span> <span id='item_unit_#{product_id}'>#{item_unit}</span></span>"
          contentStr += "<input type='hidden' name='quantity#{product_id}' value='#{item_quantity}' id='cart_item_#{product_id}'/>"
          if business_type == "by_catalog" 
            contentStr += "<input type='hidden' name='price#{product_id}' value='#{item_price}' id='cart_item_price_#{product_id}'/>"
          contentStr += "<input type='hidden' name='vendor_product_id#{product_id}' value='#{vendor_product_id}' id='cart_item_vendor_product_id#{product_id}'>"
          contentStr += "<input type='hidden' name='unit#{product_id}' value='#{item_unit_id}' id='cart_item_unit_#{product_id}'/>"
          contentStr += "</div></li>"
          $(".no-item-selected").hide()
          $(".po-product-list").prepend(contentStr)
    else
      $(".po-product-list").find("#li_product_#{product_id}").remove()
    return

  $(document).on "click", ".outlet_checkbox",->
    unit_id = $(this).data('unit-id')
    if ($(this).is ":checked")
      if destination_units.length > 5
        Materialize.toast("More than 6 outlets can't be selected together", 3000, 'red')
        return false
      else
        if $("#unit_store_#{unit_id}").val().length == 0
          Materialize.toast("Please select a store for this outlet", 3000, 'red')
          return false
        else
          if (jQuery.inArray(unit_id,destination_units)==-1)
            destination_units.push unit_id
            $("#store_unit_#{unit_id}").val($("#unit_store_#{unit_id}").val())
                     
    else
      destination_units.splice(destination_units.indexOf(unit_id), 1)
    $("#destination_units").val(destination_units)
    return

  $(document).on "change", ".unit_stores",->
    unit_id = $(this).data('unit-id')
    store_id = $(this).val()
    if store_id.length != 0
      $("#store_unit_#{unit_id}").val(store_id)
    return

  $(document).on "click", ".pom_checkbox",->
    pom_id = $(this).data("pom-id")
    product_name = $(this).data("product-name")
    if !$(this).is ":checked"
      request = $.ajax(
        type : 'POST'
        url : "/purchase_orders/remove_pom"
        data:
          pom_id: pom_id
      )
      request.done (data, textStatus, jqXHR) ->
        Materialize.toast("#{product_name} has been removed.", 5000)
        $("#pom_tr_#{pom_id}").remove()
        if $("#po_confirmation_collapse_#{pom_id}").length
          $("#po_confirmation_collapse_#{pom_id}").remove()
        console.log data
        return
      request.error (jqXHR, textStatus, errorThrown) ->
        Materialize.toast("AJAX Error", 5000)
        return
    return

  $(document).on "keyup", ".pom_qty",->
    pom_id = $(this).data("pom-id")
    product_name = $(this).data("product-name")
    quantity = $(this).val()
    quantity = 0 if quantity.length == 0
    basic_unit = $(this).data('product-basic-unit')
    if !$(this).is ":checked"
      request = $.ajax(
        type : 'POST'
        url : "/purchase_orders/update_pom"
        data:
          pom_id: pom_id
          quantity: quantity
      )
      request.done (data, textStatus, jqXHR) ->
        Materialize.toast("Quantity of #{product_name} has been updated to #{quantity} #{basic_unit}.", 5000)
        console.log data
        request_pomd = $.ajax(
          type : 'POST'
          url : "/purchase_orders/remove_all_pomd"
          data:
            pom_id: pom_id
        )
        request_pomd.done (data_pomd, textStatus_pomd, jqXHR_pomd) ->
          $(".podm_color_size_#{pom_id}").val(0)
          return
        return
      request.error (jqXHR, textStatus, errorThrown) ->
        Materialize.toast("AJAX Error", 5000)
        return
    return

  $(document).on "keypress", ".product_search", (event)->
    po_id = $(this).data('po-id')
    if event.keyCode == 13
      $(".product_add_btn").each ->
        if $(this).attr('id') == "product_add_btn_#{po_id}"
          $(this).click()
      return

  $(document).on "click", ".product_add_btn", (event)-> 
    event.preventDefault()
    po_id = $(this).data('po-id')
    product_name = $("#product_search_val_#{po_id}").val()
    store_id = $(this).data('store-id')
    request = $.ajax(
      type: 'POST'
      url: "/purchase_orders/save_pom"
      data:
        product_name: product_name
        purchase_order_id: po_id
        store_id: store_id
    )
    request.done (data, textStatus_pom, jqXHR_pom) ->
      console.log data
      product_unit = data.all_data.product_basic_unit
      current_stock = data.all_data.current_stock
      data = data.all_data.data
      contentStr = "<tr class='data-table__selectable-row' id='pom_tr_#{data.id}'>"
      contentStr += "<td class='col-lg-1 padding-l-10'>"
      contentStr += "<input checked='checked' class='checkbox-child filled-in pom_checkbox' data-pom-id='#{data.id}' data-product-name='#{product_name}' id='pom_#{data.id}' name='selected_pom[]' value='#{data.id}' type='checkbox'>"
      contentStr += "<label class='font-sz-11 padding-l-20' for='pom_#{data.id}'></label>"
      contentStr += "</td>"
      contentStr += "<td class='col-lg-5'>#{product_name}</td>"
      contentStr += "<td class='col-lg-2'><span class='label label-default'>#{current_stock}</span></td>"
      contentStr += "<td class='col-lg-4 m-input'>"
      contentStr += "<div class='row margin-l-r-none'>"
      contentStr += "<div class='col-lg-9 padding-l-r-none'>"
      contentStr += "<input class='allow-numeric-only form-control pom_qty' data-pom-id='#{data.id}' data-product-basic-unit='#{product_unit}' data-product-name='#{product_name}' value='1.0' type='text'>"
      contentStr += "</div>"
      contentStr += "<div class='col-lg-3 padding-l-r-none'>"
      contentStr += "<br>"
      contentStr += "#{product_unit}"
      contentStr += "</div>"
      contentStr += "</div>"
      contentStr += "</td>"
      contentStr += "</tr>"

      $(".po_table_#{po_id}").prepend(contentStr)
      return
    request.error (jqXHR_pom, textStatus_pom, errorThrown_pom) ->

      return


  ########### Function to send purchase order ###########
  # $(document).on "click", ".send_all_po",->
  #   $(".po_table").each () ->
  #     po_id = $(this).data('po-id')
  #     request = $.ajax(url: "/purchase_orders/send_purchase_order/?id="+po_id)
  #     request.done (data, textStatus, jqXHR) ->
  #       console.log data
  #       Materialize.toast("You have successfully sent this purchase order (PO ID: #{po_id})", 5000)
  #       return
  #     request.error (jqXHR, textStatus, errorThrown) ->
  #       Materialize.toast("There was a problem while sending this purchase order", 5000)
  #       return
  #   return

  $(document).on "click", ".po_mail", ->
    po_id = $(".po_mail").data("po-id")
    request = undefined
    request = $.ajax(url : "/purchase_orders/get_send_purchase_order_details/?id="+po_id)
    request.done (data, textStatus, jqXHR) ->
      po_result = JST["templates/purchase_orders/po_mail_details"](data)
      console.log(data)
      $('#reprintPurchaseOrderMailModal').html po_result
      $('#reprintPurchaseOrderMailModal').modal('show')
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("There was a problem while fetch purchase orders mail details.", 5000, "red")
      return
    return

  $(document).on "click", ".send_all_po",->
    smart_po_id = $(this).data('smart-po-id')
    $('.loader').css('display','block')
    $('body').css('pointer-events','none')
    request = $.ajax(url: "/purchase_orders/send_smart_po/?smart_po_id="+smart_po_id)
    request.done (data, textStatus, jqXHR) ->
      $('.loader').css('display','none')
      $('body').css('pointer-events','all')
      Materialize.toast("You have successfully sent all purchase orders", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      $('.loader').css('display','none')
      $('body').css('pointer-events','all')
      Materialize.toast("There was a problem while sending these purchase orders", 5000)
      return
    return

    ########### Function of product_color_size #############
  $(document).on "keyup change", ".product_color_size",->
    product_id = $(this).data("product-id")
    $(".estimated_cost_#{product_id}").prop("disabled", false)
    color_id = $(this).data("color-id")
    color_name = $(this).data("color-name")
    size_id = $(this).data("size-id")
    size_name = $(this).data("size-name")
    quantity = $(this).val()
    total_quantity = 0

    unit_input = $(".unit-input-#{product_id}").val()
    unit_input = unit_input.split("__")
    multiplier = parseFloat(unit_input[2])
    multiplier = 1 if isNaN(multiplier)
    item_name = $(this).data("product-name")
    item_price = $(".price_#{product_id}").val()
    vendor_product_id = $(this).data("vendor-product-id")
    item_unit = $(this).data("basic-unit")
    business_type = $(this).data("business-type")

    $("#li_product_#{product_id}").remove()

    if unit_input[0] > 0
      item_unit_id = unit_input[0]
      item_unit = unit_input[1]
    else
      item_unit_id = 0
      item_unit = $(this).data("basic-unit")
    
    $(".po_color_size_#{product_id}").each ->
      if $(this).val().length
        total_quantity += parseFloat($(this).val())
      $(".transfer-quantity-#{product_id}").val(total_quantity)
      $("#p_total_qty_#{product_id}").val total_quantity
      return

    estimated_price = (item_price*total_quantity*multiplier).toFixed(2)
    $(".estimated_cost_#{product_id}").val estimated_price

    if quantity <= 0 or isNaN(quantity)
      Materialize.toast("Please provide some quantity of #{item_name}.", 3000)
      $(".po-product-list").find("#li_product_#{product_id}_#{color_id}_#{size_id}").remove()
    else
      $(".transfer-quantity-#{product_id}").removeClass 'error-input red'
      if $("#cart_item_#{product_id}_#{color_id}_#{size_id}").length
        $("#cart_item_#{product_id}_#{color_id}_#{size_id}").val quantity
        $("#item_qty_#{product_id}_#{color_id}_#{size_id}").html quantity
        $("#item_unit_#{product_id}_#{color_id}_#{size_id}").html item_unit
        $("#product_#{product_id}_#{color_id}_#{size_id}").data 'quantity', quantity
      else
        contentStr = "<li class='collection-item li_color_size_product_#{product_id}' id='li_product_#{product_id}_#{color_id}_#{size_id}'><div>"
        contentStr += "<input type='checkbox' class='checked_raw_single_product' name='checked_raw_single_product[]' value='#{product_id}_#{color_id}_#{size_id}' id='product_#{product_id}_#{color_id}_#{size_id}' data-product-id='#{product_id}' data-quantity='#{quantity}' checked>"
        if "#{color_name}"=='undefined'
          contentStr += "<label for='product_#{product_id}_#{color_id}_#{size_id}' class='font-sz-11'>#{item_name}-#{size_name}</label>"
        else if "#{size_name}" == 'undefined'
          contentStr += "<label for='product_#{product_id}_#{color_id}_#{size_id}' class='font-sz-11'>#{item_name}-#{color_name}</label>"
        else
          contentStr += "<label for='product_#{product_id}_#{color_id}_#{size_id}' class='font-sz-11'>#{item_name}-#{color_name}-#{size_name}</label>"
        contentStr += "<span class='secondary-content font-sz-11'><span id='item_qty_#{product_id}_#{color_id}_#{size_id}'>#{quantity}</span> <span id='item_unit_#{product_id}_#{color_id}_#{size_id}'>#{item_unit}</span></span>"
        contentStr += "<input type='hidden' name='single_item_quantity#{product_id}_#{color_id}_#{size_id}' value='#{quantity}' id='cart_item_#{product_id}_#{color_id}_#{size_id}'/>"
        
        contentStr += "</div></li>"
        $(".no-item-selected").hide()
        $(".po-product-list").prepend(contentStr)

    # if $(".product_color_size_quantity_#{product_id}_#{color_id}_#{size_id}").length
    #   $(".product_color_size_quantity_#{product_id}_#{color_id}_#{size_id}").val quantity
    # else
    #   singleItemContentStr = "<input type='checkbox' class='checked_product_color_size_#{product_id}_#{color_id}_#{size_id}' name='checked_raw_color_size_product_#{product_id}[]' value='#{color_id}_#{size_id}' checked>"
    #   singleItemContentStr += "<input type='hidden' class='product_color_size_quantity_#{product_id}_#{color_id}_#{size_id}' name='product_color_size_quantity_#{product_id}_#{color_id}_#{size_id}' value='#{quantity}'>"

    #   $("#li_product_#{product_id}_#{color_id}_#{size_id}").prepend(singleItemContentStr)
    
    if total_quantity <= 0 or isNaN(total_quantity)
      Materialize.toast("Please provide some quantity of #{item_name}.", 3000)
      $(".po-product-list").find("#li_product_#{product_id}").remove()
    else
      $(".transfer-quantity-#{product_id}").removeClass 'error-input red'
      if $("#cart_item_#{product_id}").length
        $("#cart_item_#{product_id}").val total_quantity
        $("#cart_item_unit_#{product_id}").val item_unit_id
        $("#cart_item_price_#{product_id}").val item_price
      else

        totalContentStr = "<li style='display:none;' class='collection-item' id='li_product_#{product_id}'><div>"
        totalContentStr += "<input type='checkbox' name='checked_raw[]' value='#{product_id}' id='product_#{product_id}' checked>"

        totalContentStr += "<input type='hidden' name='quantity#{product_id}' value='#{total_quantity}' id='cart_item_#{product_id}'/>"
        if business_type == "by_catalog" 
          totalContentStr += "<input type='hidden' name='price#{product_id}' value='#{item_price}' id='cart_item_price_#{product_id}'/>"
        totalContentStr += "<input type='hidden' name='vendor_product_id#{product_id}' value='#{vendor_product_id}' id='cart_item_vendor_product_id#{product_id}'>"
        totalContentStr += "<input type='hidden' name='unit#{product_id}' value='#{item_unit_id}' id='cart_item_unit_#{product_id}'/>"

        # $("#li_product_#{product_id}").prepend(totalContentStr)
        $(".po-product-list").prepend(totalContentStr)
    $(".po_checkbox_#{product_id}").prop("checked",true)
    return 

  $(document).on "click", ".checked_raw_single_product" ,->
    product_color_size_id = $(this).val()
    product_id = $(this).data('product-id')
    quantity = $(this).data('quantity')
    old_total_quantity = $("#p_total_qty_#{product_id}").val()
    unit_input = $(".unit-input-#{product_id}").val()
    unit_input = unit_input.split("__")
    multiplier = parseFloat(unit_input[2])
    multiplier = 1 if isNaN(multiplier)
    item_price = $(".price_#{product_id}").val()
    
    if !$(this).is(':checked')
      new_total_quantity = parseFloat(old_total_quantity) - parseFloat(quantity)
      $(".po_color_size_#{product_color_size_id}").val 0
    else
      new_total_quantity = parseFloat(old_total_quantity) + parseFloat(quantity)
      $(".po_color_size_#{product_color_size_id}").val quantity
      
    $("#cart_item_#{product_id}").val new_total_quantity
    $(".transfer-quantity-#{product_id}").val new_total_quantity
    $("#p_total_qty_#{product_id}").val new_total_quantity

    estimated_price = (item_price*new_total_quantity*multiplier).toFixed(2)
    $(".estimated_cost_#{product_id}").val estimated_price

    return

  $(document).on "click","#product_add_po_edit",(event) ->
    product_id  = $("#product-search-po-edit").attr("data-product-id")
    vendor_id = $("#po_vendor_id").val()
    flag = false
    $(".meta_products").each ->
      if $(this).attr("data-product-id") == product_id
        Materialize.toast("The product is already in the PO , if you want to add it please increase the quantity", 4000, 'red')
        flag = true
        return
    if flag == false
      request = $.ajax(
        type : 'GET'
        url : "/purchase_orders/vendor_product_price"
        data:
          product_id: product_id
          vendor_id: vendor_id
      )
      request.done (data, textStatus, jqXHR) ->
        console.log(data)
        if data == null
          Materialize.toast("#{product_name} is not added to the vendor.", 4000, 'red')
          return
        vendor_price = data["price"]
        content_str = "<tr class=' new_meta_product_#{product_id} meta_products' data-product-id=#{data['product_id']}>"
        content_str += "<td>sl</td>"
        content_str += "<td>#{product_name}</td>"
        content_str += "<td><input class='form-control price_#{data['product_id']} product_price' name='purchase_orders[][price_per_unit]' value=#{vendor_price} data-product-id=#{data['product_id']}></input></td>"
        content_str += "<td><input class='allow-numeric-only form-control margin-b-2 purchase-input input_quantity transfer-quantity-#{data['product_id']}' name='purchase_orders[][product_amount]' data-product-id=#{data['product_id']}></input></td>"
        content_str += "<td><input class='allow-numeric-only estimated_cost_#{data['product_id']} form-control product_estmated_cose'></input></td>"
        content_str += "<td><div class='m-btn red m-btn-low-padding cancel_item_in_po' data-product-name=#{product_name} data-product-id=#{data['product_id']} title='cancel item in po'>"
        content_str += "<i class='mdi-action-highlight-remove'></i>"
        content_str += "</div></td>"
        content_str += "<input type='hidden' name='purchase_orders[][product_id]' value=#{product_id}></input>"
        content_str += "<input type='hidden' name='purchase_orders[][action]' value=new></input>"
        content_str += "</tr>"
        $(".dynamic_product_add").append(content_str)
        return
      request.error (jqXHR, textStatus, errorThrown) ->
        Materialize.toast("AJAX Error", 5000)
        return
      product_name = $("#product-search-po-edit").val()  
    return

  ########### Function to calculate estimated cost #############################
  # $(document).on "keyup change", ".input_quantity",->
  #   product_id = $(this).data("product-id")
  #   item_price = $(".price_#{product_id}").val()
  #   quantity = $(".transfer-quantity-#{product_id}").val()
  #   unit_input = $(".unit-input-#{product_id}").val()
  #   unit_input = unit_input.split("__")
  #   multiplier = parseFloat(unit_input[2])
  #   multiplier = 1 if isNaN(multiplier)
  #   estimated_price = (item_price*quantity*multiplier).toFixed(2)
    
  #   $(".estimated_cost_#{product_id}").val estimated_price

  #   return

  # $(document).on "keyup change", ".total_input_quantity",->
  #   product_id = $(this).data("product-id")
  #   alert product_id
  #   item_price = $(".price_#{product_id}").val()
  #   quantity = $(".transfer-quantity-#{product_id}").val()
  #   unit_input = $(".unit-input-#{product_id}").val()
  #   unit_input = unit_input.split("__")
  #   multiplier = parseFloat(unit_input[2])
  #   multiplier = 1 if isNaN(multiplier)
  #   estimated_price = (item_price*quantity*multiplier).toFixed(2)
    
  #   $(".estimated_cost_#{product_id}").val estimated_price
  #   $(".po_color_size_#{product_id}").val(0)
  #   $("#p_total_qty_#{product_id}").val(0)
  #   $(".li_color_size_product_#{product_id}").remove()

  #   return

  $(document).on "keyup", ".podm_color_size",->
    po_id = $(this).data('po-id')
    pom_id = $(this).data('pom-id')
    product_id = $(this).data('product-id')
    color_id = $(this).data("color-id")
    size_id = $(this).data("size-id")
    quantity = parseFloat($(this).val())
    total_quantity = 0
    product_name = $("#pom_#{pom_id}").data("product-name")
    basic_unit = $(this).data('product-basic-unit')
    $(".podm_color_size_#{pom_id}").each ->
      if $(this).val().length
        total_quantity += parseFloat($(this).val())
      return
    request_pomd = $.ajax(
      type : 'POST'
      url : "/purchase_orders/update_pomd"
      data:
        po_id: po_id
        pom_id: pom_id
        product_id: product_id
        color_id: color_id
        size_id: size_id
        quantity: quantity
    )
    request = $.ajax(
      type : 'POST'
      url : "/purchase_orders/update_pom"
      data:
        pom_id: pom_id
        quantity: total_quantity
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Quantity of #{product_name} has been updated to #{total_quantity} #{basic_unit}.", 5000)
      $("#pom_qty_#{pom_id}").val(total_quantity)
      console.log data
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error", 5000)
      return
    return