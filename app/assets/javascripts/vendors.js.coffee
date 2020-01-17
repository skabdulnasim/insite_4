$(document).ready ->
  $(document).on "change", "#unittype_id",->
    request = $.ajax(url: "/vendors/get_selected_unittype.json?unittype_id="+this.value)
    request.done (data, textStatus, jqXHR) ->
      data.units = data
      console.log data
      result = JST["templates/vendors/get_selected_unittype"](data)
      $("#unit_select").html result
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "AJAX Error:" + textStatus
      return
    return

  ########### Function to add products to temporary cart to allocate t unit ###########
  $(document).on "click", ".select-unit-products",->
    unit_id = $(this).data('unit-id')
    request = $.ajax(url: "/api/v2/sections/section_tax_groups.json?unit_id="+unit_id)
    request.done (data, textStatus, jqXHR) ->
      tax_groups = data.data.tax_groups
      $('.available-products:checkbox:checked').map ->
        product_id = @value
        item_name = $(this).data("product-name") 
        item_unit = $(this).data("product-unit")     
        if $("#cart_item_#{product_id}").length
          Materialize.toast("#{item_name} already selected.", 3000, 'rounded')
        else
          # Materialize.toast("#{item_name} selected.", 3000, 'rounded')
          contentString = "<tr class='data-table__selectable-row' id='cart_item_#{product_id}'>"
          contentString += "<td>##{product_id}<input type='hidden' name='products[]' value='#{product_id}'></td>"
          contentString += "<td>#{item_name}</td>"
          contentString += "<td><select class='form-control' name='tax_group_id#{product_id}'>"
          contentString += "<option value=''>select tax group</option>"
          _.each tax_groups, (tax_group, idx) ->
            contentString += "<option value=#{tax_group.id}>#{tax_group.name}</option>"
          contentString += "</select></td>"
          contentString += "<td><input type='text' name='price#{product_id}' placeholder='Enter Price per unit #{item_unit}'></td>"
          contentString += "</tr>"
          $(".no-item-selected").hide()
          $(".unit-product-list").prepend(contentString)
        return
    return  

  $(document).on 'change', '#vendor_phone', (evt) ->
    length = $(this).val().length
    if (length >= 13|| length < 10)
      $(this).addClass('error-rais')
      Materialize.toast("Enter Valid phone no", 3000, 'red')
      $('#vendor_phone').focus()
      return false
    else
      $(this).removeClass('error-rais')  
    return

  $(document).on 'change', '#payment_mode', (evt) ->
    if $(this).val() == "cheque"
      $("#cheque_details").show()
      $("#cheque_details").attr('disabled', false)
      $("#neft_details").hide()
      $("#neft_details").attr('disabled', true)
    else if $(this).val() == "neft"
      $("#neft_details").attr('disabled', false)
      $("#neft_details").show()
      $("#cheque_details").hide()
      $("#cheque_details").attr('disabled', true)
    else
      $("#neft_details").hide()
      $("#neft_details").attr('disabled', true)
      $("#cheque_details").hide()
      $("#cheque_details").attr('disabled', true)
    return  

  $(document).on 'keyup', '#payment_amount', (evt) ->
    amount = parseFloat($(this).val())
    due = parseFloat($("#due_amount").val())
    if (amount > due)
      $(this).addClass('error-rais')
      Materialize.toast("Paid amount geater than due amount", 3000, 'red')
      $(".payment-save").attr('disabled', true)
    else
      $(this).removeClass('error-rais')  
      $(".payment-save").attr('disabled', false)
    return
  
  $(document) .on "click", '.stock-purchase-payment', ->
    $("#details").hide()
    stock_puchase_id = $(this).data("stock-purchase-id")
    $(".stock_purchase_id_payment").val(stock_puchase_id)
    $("#payment_amount").val($(this).data("due-amount"))
    $("#due_amount").val($(this).data("due-amount"))
    $(".payment-title").html ""
    $(".payment-title").html("Make a payment (Due Amount : #{$(this).data("due-amount")})")
    return

  $(document).on "click", '.stock-purchase-quickview', ->
    stock_puchase_id = $(this).data("stock-purchase-id")
    loader_data = {loader_type: 'color-spinner'}
    currency = $(this).data("currency")
    loader = JST['templates/loader'](loader_data)
    $("#stock_purchase_quickinfo_#{stock_puchase_id}").html loader
    request = $.ajax(url: "/api/v2/stock_purchases/get_payment_details.json?id="+stock_puchase_id)
    request.done (data, textStatus, jqXHR) ->
      data.attributes = data
      data.currency = currency
      console.log data
      result = JST["templates/stock_purchases/payment_details"](data)
      $("#stock_purchase_quickinfo_#{stock_puchase_id}").html result
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "AJAX Error:" + textStatus
      return
    return 

  $(document).on 'keyup', '#vendor_phone', (evt) ->
    length = $(this).val().length
    value = $(this).val()
    if (length > 13)
      $(this).addClass('error-rais')
      Materialize.toast("Enter Valid phone no", 3000, 'red')
      $('#vendor_phone').val('')
      $('#vendor_phone').focus()
      return false
    else
      $(this).removeClass('error-rais')  
    return
