# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  $(document).on "click", ".order-quickview", ->
    order_id = $(this).data("order-id")
    currency = $(this).data("currency")
    data = {loader_type: 'color-spinner'}
    loader = JST['templates/loader'](data)
    $("#order_quickinfo_#{order_id}").html loader
    request = $.ajax(
      type: 'GET'
      url: "/api/v2/orders/#{order_id}.json"
      dataType: "json"
    )
    request.done (data, textStatus, jqXHR) ->  
      $(".order_collapse_#{order_id}").removeClass 'order-quickview'
      data.response = data
      console.log data
      data.currency = currency
      result = JST["templates/orders/quick_details"](data)
      $("#order_quickinfo_#{order_id}").html result
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      $("#order_quickinfo_#{order_id}").html textStatus
      return
    return

  $(document).on 'click', '.order-canceal-confirm', ->
    order_id = $(this).attr("id")
    cause = $("#id_#{order_id}").val()
    if (cause.length == 0)
      $("#id_#{order_id}").addClass("error-message")
    else
      $("#error_#{order_id}").html("")
      $("#cancelOrderModal_#{order_id}").modal "hide"
      request = undefined
      request = $.ajax(url: "/orders/cancel_order?id="+order_id+"&cancel_cause="+cause)
    return

  $(document).on 'click', '.kot-canceal-confirm', ->
    order_details_id = $(this).data("kot-id")
    cause = $("#kot_cause_#{order_details_id}").val()
    if (cause.length == 0)
      $("#kot_cause_#{order_details_id}").addClass("error-message")
    else
      $("#cancelKotModal_#{order_details_id}").modal "hide"
      request = undefined
      request = $.ajax(url: "/orders/cancel_order_product?order_details_id="+order_details_id+"&cancel_cause="+cause)
      request.done (data, textStatus, jqXHR) ->
        $("#kotcancel_#{order_details_id}").hide()
        $("#staus_#{order_details_id}").hide()
        $("#cancel_staus_#{order_details_id}").removeClass("hide")
        $("#kot_cancel_cause_#{order_details_id}").removeClass("hide")
        $("#kot_cancel_cause_#{order_details_id}").html(cause)
        Materialize.toast("You have succesfully canceled this item", 3000, 'rounded')
        return
      request.error (jqXHR, textStatus, errorThrown) ->
        alert "AJAX Error:" + textStatus
        return
    return

  $(document).on 'click', '.update_order_status', ->
    order_id = $(this).data("order-id")
    order_status_id = $(this).data("value-active")
    current_user = $(".current_user_id").val() 
    request = undefined
    request = $.ajax(
      type: 'POST'
      url: "/orders/update_order_state/?order_id="+order_id+"&order_status_id="+order_status_id+"&user_id="+current_user
      dataType: "json"
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Order updated to new state", 3000, 'green')
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("Something went weong", 3000, 'red')
    return  

  $(document).on 'click', '#stock_isue', ->
    $('.select-order:checkbox:checked').map ->
      order_id = $(this).data('order-id')
      request = undefined
      request = $.ajax(url: "/orders/issue_stock/?id="+order_id)
      request.done (data, textStatus, jqXHR) ->
        console.log data
        if data.success
          Materialize.toast("#{data.success} for order #{order_id}", 3000, 'green')
          $(".remove-icon-#{order_id}").remove()
          #$(".remove_checkbox_#{order_id}").remove()
          $(".remove_checkbox_#{order_id}").attr("disabled", true);
        else
          Materialize.toast("#{data.error} for order #{order_id}", 3000, 'red')
        return
      request.error (jqXHR, textStatus, errorThrown) ->
        alert "AJAX Error:" + textStatus
        return
    return

  $(document).on "click", "#order_accumulation",->
    future_orders_array = []
    $('.select-future-order:checkbox:checked').map ->
      future_order_id = $(this).data('order-id')
      future_orders_array.push future_order_id
    $("#future_orders_array").val future_orders_array
    return

  ########### Function to add products to temporary cart with quantity###########
  $(document).on "keyup", ".add-products-to-temp-cart",->
    product_id = $(this).data("product-id")
    item_name = $(this).data("product-name")
    item_unit = $(this).data("product-unit")
    item_quantity = $(".quantity_#{product_id}").val()
    if item_quantity <= 0
      Materialize.toast("OOPS! Please provide some quantity of #{item_name}.", 3000)
      $(".po-product-list").find("#li_product_#{product_id}").remove()
    else
      if $("#cart_item_#{product_id}").length
        Materialize.toast("#{item_name} updated.", 3000, 'rounded')
        $("#cart_item_#{product_id}").val item_quantity
        $("#item_qty_#{product_id}").html item_quantity
      else
        Materialize.toast("#{item_name} selected.", 3000, 'rounded')
        contentStr = "<li class='collection-item' id='li_product_#{product_id}'><div>"
        contentStr += "<input type='checkbox' name='checked_raw[]' value='#{product_id}'/ id='product_#{product_id}' checked>"
        contentStr += "<label for='product_#{product_id}' class='font-sz-11'>#{item_name}</label>"
        contentStr += "<span class='secondary-content font-sz-11'><span id='item_qty_#{product_id}'>#{item_quantity}</span> #{item_unit}</span>"
        contentStr += "<input type='hidden' name='quantity#{product_id}' value='#{item_quantity}' id='cart_item_#{product_id}'/>"
        # contentStr += "<input type='hidden' name='checked_raw[]' value='#{product_id}'/>"
        contentStr += "</div></li>"
        $(".no-item-selected").hide()
        $(".po-product-list").append(contentStr)
    return