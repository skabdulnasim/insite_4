# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->


  $(document).on 'click', '#add_discount', ->
    discount = parseFloat($("#discount").val())
    remarks = $("#remarks").val()
    email_id = $(".current_user_email").val()
    device_id = 'YOTTO05'
    if discount > 100
      Materialize.toast("Sorry!! Please provide discount percentage lessthan or equels to (100).", 3000,'red')
    else if discount <= 0 or isNaN(discount)
      Materialize.toast("Sorry!! Please provide discount amount.", 3000,'red')
    else if remarks is ""
      Materialize.toast("Sorry!! Please provide discount remarks.", 3000,'red')    
    else  
      $('#billDiscountModal').modal("hide")

      $('.select-bill:checkbox:checked').map ->
        bill_id = $(this).data('bill-id')
        bill_total = parseFloat($(this).data('bill-amount'))
        discount_amount = (bill_total * discount)/100
        bill_update_request = $.ajax(
          type: 'PUT'
          url: "/api/v2/bills/#{bill_id}.json"
          dataType: "json"
          data:
            email           : email_id
            device_id       : device_id
            bill:
              bill_discount_percentage : discount
              bill_discounts_attributes : [{"discount_amount": discount_amount,"remarks": remarks}]  
        )  
        bill_update_request.done (data, textStatus, jqXHR) ->
          Materialize.toast("Bill ID #{bill_id} updated.", 3000,'green')
          $(".remove_checkbox_#{bill_id}").attr("disabled", true)
          $(".remove_checkbox_#{bill_id}").removeClass 'select-bill'
        bill_update_request.error (jqXHR, textStatus, errorThrown) ->
          Materialize.toast("#{jqXHR.responseText}", 3000,'red')
          return
        return
      return  
    return

  $('.bill-discount').on 'click', (e) ->    
    bc_length = $('.select-bill:checkbox:checked').length
    if bc_length < 1
      Materialize.toast("Select Bill First", 3000, 'red')
      e.stopPropagation()
    return  
  
  #Open reprint layout
  $(document).on "click",".reprint", ->
    bill_id=$(this).data("bill-id")
    action=$(this).data("action")
    request=$.ajax(
        type: 'GET'
        url: "api/v2/bill_reprints/#{bill_id}.json"
        dataType: 'json'
      )
    request.done (responseData, textStatus, jqXHR) ->
      console.log('data fetched successfully')
      data = responseData.data
      data.response=data
      data.action=action
      console.log(data)
      result = JST["templates/bills/quick_details"](data)
      $("#bill_quickinfo_#{bill_id}").html result
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      console.log('error')
      return
    return

  # Bill quickview action
  $(document).on "click", ".bill-quickview, .edit-bill-link, .cancel_update_bill, .bill-settlement-link, .add-discount-link, .return-item", ->
    $("#returnStoresModal").modal('hide')
    action = $(this).data("action")
    bill_id = $(this).data("bill-id")
    currency = $(this).data("currency")
    return_store_id = $("#return_store").val()
    get_bill_details(bill_id,currency,action,return_store_id)
    return

  # Generic function to get bill details
  get_bill_details = (bill_id,currency,action,return_store_id) ->
    # preloader
    loader_data = {loader_type: 'color-spinner'}
    loader = JST['templates/loader'](loader_data)
    $("#bill_quickinfo_#{bill_id}").html loader
    # Getting data through AJAX
    request = $.ajax(
      type: 'GET'
      url: "/api/v2/bills/#{bill_id}.json"
      dataType: "json"
    )
    request.done (responseData, textStatus, jqXHR) ->
      # Materialize.toast("#{responseData.messages.simple_message}", 5000)
      data = responseData.data
      console.log(data)
      $(".bill_grand_total_#{bill_id}").html data.grand_total
      status_content = get_bill_status(data.status)
      $(".bill_status_#{bill_id}").html status_content
      data.response = data
      data.currency = currency
      data.action = action
      data.return_store_id = return_store_id
      result = JST["templates/bills/quick_details"](data)
      $("#bill_quickinfo_#{bill_id}").html result
      $(".nc-actions").hide()
      $(".bill_remarks").hide()
      $(".bill_split").hide()
      $(".user_details_#{bill_id}").hide()
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      $("#bill_quickinfo_#{bill_id}").html textStatus
      return
    return
  get_bill_status = (status) ->
    statusStr = ""
    if status is "unpaid"
      statusStr = "<span class='m-label orange'>Unpaid</span>"
    else if status is "paid"
      statusStr = "<span class='m-label green'>Paid</span>"
    else if status is "void"
      statusStr = "<span class='m-label red'>Void</span>"
    else if status is "no_charge"
      statusStr = "<span class='m-label grey'>No charge</span>"
    else if status is "cod"
      statusStr = "<span class='m-label blue'>COD</span>"
    else if status is "boh"
      statusStr = "<span class='m-label pink'>BOH</span>"  
    else if status is "cancled"
      statusStr = "<span class='m-label black'>CANCLED</span>"      
    return statusStr

  # Updating order details attributes
  $(document).on "change", ".bill_status_change", ->
    bill_id = $(this).attr("id")    
    bill_status = $(".bill_status_edt_frm_#{bill_id}").val()
    $(".user_details_#{bill_id}").find('input:text').val('')
    $(".user_details_#{bill_id}").find('input:hidden').val('')
    if bill_status is "void" or bill_status is "no_charge"
      $(".bill_split_#{bill_id}").hide()
      $(".bill_remarks_#{bill_id}").show()
      $(".customer_details_#{bill_id}").hide()
      $(".update_order_item_#{bill_id}").show()
      $(".user_details_#{bill_id}").hide()
      $("#bill_update_#{bill_id}").prop('disabled', false)
    else if bill_status is "boh"
      $(".bill_remarks_#{bill_id}").hide()
      $(".update_order_item_#{bill_id}").hide()
      $(".customer_details_#{bill_id}").hide()
      $(".customer_mobile_#{bill_id}").show()
      $(".bill_split_#{bill_id}").show()
      $(".user_details_#{bill_id}").show()
      $("#bill_update_#{bill_id}").prop('disabled', true)
    else   
      $(".bill_remarks_#{bill_id}").hide()
      $(".bill_split_#{bill_id}").hide()
      $(".customer_details_#{bill_id}").hide()
      $(".user_details_#{bill_id}").hide()
      $(".update_order_item_#{bill_id}").show()
      $("#bill_update_#{bill_id}").prop('disabled', false)
    return

  #calculate boh amount
  $(document).on "keyup change",".bill_paid_amount", ->
    bill_id = $(this).data("bill-id")
    grand_total = parseFloat($(".grand_total_#{bill_id}").val())
    paid_amount = parseFloat($(this).val())
    if paid_amount > grand_total
      Materialize.toast("Oops! Paid amount is greater than grand total.", 3000,'round')
    else  
      unpaid_amount = grand_total - paid_amount
      unpaid_amount = grand_total if isNaN(unpaid_amount)
      $(".bill_unpaid_amount_#{bill_id}").val(unpaid_amount)
    return 

  # Updating order details attributes
  $(document).on "click", ".change_order_item_status", ->
    id = $(this).attr('data-id')
    if (this.checked)
      $(".nc-actions-#{id}").show()
    else
      $(".nc-actions-#{id}").hide()
    return

  # Updating order details attributes
  $(document).on "click", ".update_order_item", ->
    if confirm('This change can not be reversed later. Are you sure about this update? ')
      order_detail_id = $(this).data("order-detail-id")
      pro_name = $(this).data("product-name")
      remarks = $("#nc_remarks_#{order_detail_id}").val()
      if remarks is ""
        Materialize.toast("Please provide remarks no charge of #{pro_name}.", 5000)
      else
        order_detail_update_request = $.ajax(
          type: 'PUT'
          url: "/order_details/#{order_detail_id}.json"
          dataType: "json"
          async: false
          data:
            bill_status: 'no_charge'
            remarks: remarks
        )
        order_detail_update_request.done (data, textStatus, jqXHR) ->
          Materialize.toast("#{pro_name} updated.", 5000)
          $(".nc_success_#{order_detail_id}").html("<span class='m-label margin-l-none red'>No charge</span> <span class='grey-text'>#{remarks}</span>")
        order_detail_update_request.error (jqXHR, textStatus, errorThrown) ->
          Materialize.toast("Error.#{textStatus} #{errorThrown}", 5000)
    return

  # Bill edit action
  $(document).on "click", ".update_bill", ->
    bill_id = $(this).data("bill-id")    
    currency = $(this).data("currency")
    action = $(this).data("action")
    discount = parseFloat($("#bill_discount_#{bill_id}").val())
    bill_amount = parseFloat($("#bill_amount_#{bill_id}").val())
    tax_amount = parseFloat($("#tax_amount_#{bill_id}").val())
    bill_status = $(".bill_status_edt_frm_#{bill_id}").val()
    bill_remarks = ""
    email_id = $(".current_user_email").val()
    device_id = 'YOTTO05'
    user_id = $(".current_user_id").val()
    unit_id = $(".current_unit_id").val() 
    split_type = "by_amount"  
    if bill_status is "void" or bill_status is "no_charge"
      bill_remarks = $(".bill_remarks_edt_frm_#{bill_id}").val()
    if discount > (bill_amount + tax_amount)
      Materialize.toast("Sorry!! Discount can't be greater than bill amount.", 5000)
    else
      if bill_status is "boh"
        boh_amount = $(".grand_total_#{bill_id}").val()
        customre_id = $(".customer_id_#{bill_id}").val()
        bill_remarks = $(".bill_split_remarks_#{bill_id}").val()
        paid_amount = $(".bill_paid_amount_#{bill_id}").val()
        unpaid_amount = $(".bill_unpaid_amount_#{bill_id}").val()  
        if bill_remarks is ""
          Materialize.toast("Please provide remarks.", 5000)
        else if paid_amount == '0'
          Materialize.toast("Please Enter Paid Amount.", 5000)
        else  
          bill_split bill_id, bill_status, bill_remarks, currency, action, email_id, device_id, user_id, unit_id, split_type, paid_amount, unpaid_amount, customre_id, boh_amount
      else  
        bill_update bill_id, bill_status, bill_remarks, currency, action 
    return

  bill_update = (bill_id, bill_status, bill_remarks, currency, action) ->
    bill_update_request = $.ajax(
      type: 'PUT'
      url: "/bills/#{bill_id}.json"
      dataType: "json"
      data:
        bill_id:      bill_id
        status:       bill_status
        remarks:      bill_remarks
    )
    bill_update_request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Bill ID #{bill_id} updated.", 5000)
      get_bill_details(bill_id,currency,action)
    bill_update_request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("#{textStatus}", 5000)
      return
    return  

  bill_split = (bill_id, bill_status, bill_remarks, currency, action, email_id, device_id, user_id, unit_id, split_type, paid_amount, unpaid_amount, customre_id, boh_amount)->
    bill_update_request = $.ajax(
      type: 'PUT'
      url: "/api/v2/bills/#{bill_id}.json"
      dataType: "json"
      data:
        email           : email_id
        device_id       : device_id
        bill:
          status        : bill_status
          boh_amount    : boh_amount
          customer_id   : customre_id
          biller_type   : 'User'
          biller_id     : user_id  
          bill_splits_attributes : [{"user_id": user_id,"unit_id": unit_id, "split_type": split_type , "grand_total":paid_amount, "remarks":bill_remarks, "biller_id":user_id },{"user_id": user_id,"unit_id": unit_id, "split_type": split_type , "grand_total":unpaid_amount, "biller_id":user_id}]
      )  
    bill_update_request.done (data, textStatus, jqXHR) ->
      console.log data
      Materialize.toast("Bill ID #{bill_id} updated.", 5000)
      get_bill_details(bill_id,currency,action)
    bill_update_request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("#{textStatus}", 5000)
      return
    return  
  #Email validation  
  validateEmail = (emailAddress) ->
    pattern = /^([a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+(\.[a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+)*|"((([ \t]*\r\n)?[ \t]+)?([\x01-\x08\x0b\x0c\x0e-\x1f\x7f\x21\x23-\x5b\x5d-\x7e\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|\\[\x01-\x09\x0b\x0c\x0d-\x7f\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))*(([ \t]*\r\n)?[ \t]+)?")@(([a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.)+([a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.?$/i
    pattern.test emailAddress  
  
  # Bill edit action
  $(document).on "click", ".check_promo_code", ->
    bill_id = $(this).data("bill-id")
    bill_amount = parseFloat($(this).data("bill-amount"))
    currency = $(this).data("currency")
    code = $("#promo_code_#{bill_id}").val()
    if code is ""
      Materialize.toast("Please provide promo code.", 5000)
    else
      promo_request = $.ajax(
        type: 'GET'
        url: "/alpha_promotions.json"
        dataType: "json"
        data:
          promo_code: code
      )
      promo_request.done (data, textStatus, jqXHR) ->
        promo_code = data[0]
        if promo_code
          amount = promo_code.promo_value if promo_code.promo_type is "by_amount"
          amount = (bill_amount * promo_code.promo_value / 100) if promo_code.promo_type is "by_percentage"
          amount = bill_amount if amount > bill_amount
          $("#promo_value_#{bill_id}").val(amount)
          Materialize.toast("#{currency} #{amount} discount can be applied using promo code #{code}.", 5000)
        else
          $("#promo_value_#{bill_id}").val("")
          Materialize.toast("Promo code #{code} not found.", 5000)
        return
      promo_request.error (jqXHR, textStatus, errorThrown) ->
        Materialize.toast("#{textStatus}", 5000)
        return
      return
    return

  $(document).on 'click', '.return-item-link', ->
    bill_id = $(this).data("bill-id")
    currency = $(this).data("currency")
    action = $(this).data("action")
    request = $.ajax(
      type: 'GET'
      url: "/return_items/show_stores.json"
      dataType: "json"
    )
    request.done (data, textStatus, jqXHR) ->
      data.response = data
      data.currency = currency
      data.action = action
      data.bill_id = bill_id
      result = JST["templates/bills/list_stores"](data)
      # $("#returnStoresModalDetails").html result
      $("#bill_quickinfo_#{bill_id}").html result
    request.error (jqXHR, textStatus, errorThrown) ->
    return

  # Bill edit action
  $(document).on "click", ".add_bill_discount", ->
    bill_id = $(this).data("bill-id")
    currency = $(this).data("currency")
    action = $(this).data("action")

    discount = parseFloat($("#add_discount_#{bill_id}").val())
    remarks = $("#discount_remarks_#{bill_id}").val()

    if discount <= 0
      Materialize.toast("Sorry!! Please provide discount amount.", 5000)
    else if remarks is ""
      Materialize.toast("Sorry!! Please provide discount remarks.", 5000)
    else
      bill_update_request = $.ajax(
        type: 'PUT'
        url: "/bills/#{bill_id}.json"
        dataType: "json"
        data:
          bill_id:      bill_id
          discount:     discount
          remarks:      remarks
      )
      bill_update_request.done (data, textStatus, jqXHR) ->
        Materialize.toast("Bill ID #{bill_id} updated.", 5000)
        get_bill_details(bill_id,currency,action)
      bill_update_request.error (jqXHR, textStatus, errorThrown) ->
        Materialize.toast("#{jqXHR.responseText}", 5000)
        return
      return
    return

  # Bill edit action
  $(document).on "click", ".apply_promo_code", ->
    bill_id = $(this).data("bill-id")
    currency = $(this).data("currency")
    action = $(this).data("action")
    code = $("#promo_code_#{bill_id}").val()

    if code is ""
      Materialize.toast("Please provide promo code.", 5000)
    else
      promo_code_request = $.ajax(
        type: 'PUT'
        url: "/bills/#{bill_id}.json"
        dataType: "json"
        data:
          bill_id:      bill_id
          promo_code:   code
      )
      promo_code_request.done (data, textStatus, jqXHR) ->
        Materialize.toast("Bill ID #{bill_id} updated.", 5000)
        get_bill_details(bill_id,currency,action)
      promo_code_request.error (jqXHR, textStatus, errorThrown) ->
        Materialize.toast("#{jqXHR.responseText}", 5000)
        return
      return
    return

  # Bill Filtering
  $(document).on "click", ".payment-mode-type", ->

    $('.payment-mode-options').prop('checked', false).trigger("change")
    if $(this).val() is "ThirdPartyPayment"
      $('.coupon-payment').hide()
      $('.third-party-payment').show()
    else if $(this).val() is "CouponPayment"
      $('.third-party-payment').hide()
      $('.coupon-payment').show()
    else
      $('.third-party-payment, .coupon-payment').hide()
    return

  $(document).on "change keyup", ".customer-mobile-no", ->
    mobile_no = $(this).val()
    bill_id = $(this).data("bill-id")
    if mobile_no.length == 10
      request = undefined
      request = $.ajax(url: "/customers/find.json?login="+mobile_no)
      request.done (data, textStatus, jqXHR) ->
        $(".customer_details_#{bill_id}").show()
        $("#create_customer_#{bill_id}").hide()
        $("#update_customer_#{bill_id}").show()
        $(".customer_id_#{bill_id}").val(data.id)
        $(".profile_id_#{bill_id}").val(data.profile.id)
        if data.profile.lastname == null
          $(".customer_name_#{bill_id}").val(data.profile.firstname)
        else  
          $(".customer_name_#{bill_id}").val(data.profile.firstname+" "+data.profile.lastname)
        $(".customer_email_#{bill_id}").val(data.email)
        $("#bill_update_#{bill_id}").prop('disabled', false)
      request.error (jqXHR, textStatus, errorThrown) ->
        $(".customer_details_#{bill_id}").find('input:text').val('')        
        $(".customer_details_#{bill_id}").find(".customer_email_#{bill_id}").val('')
        $(".customer_details_#{bill_id}").find('input:hidden').val('')
        $("#create_customer_#{bill_id}").show()
        $("#update_customer_#{bill_id}").hide()
        $(".customer_details_#{bill_id}").show()
    return  

  $(document).on "click", ".create_customer", ->
    bill_id = $(this).data("bill-id")
    email = $(".customer_email_#{bill_id}").val()
    mobile_no = $(".customer-mobile-no").val()
    name = $(".customer_name_#{bill_id}").val()
    if name == "" 
      Materialize.toast("Oops! Name can't blank.", 3000,'round')
    else if mobile_no == ""
      Materialize.toast("Oops! Contact No can't blank.", 3000,'round')
    else if mobile_no.length < 10
      Materialize.toast("Oops! Contact No Must be 10 digit.", 3000,'round')
    else if !validateEmail(email)
      Materialize.toast("Provide valid Email.", 3000,'round')
    else
      customer_param = { "customer" : { "email" : "#{email}", "mobile_no" : "#{mobile_no}", "customer_profile_attributes" : { "customer_name" : "#{name}", "contact_no" : "#{mobile_no}" } } }
      request = undefined
      request = $.ajax(
        type: 'POST',
        url: "/customers.json/",
        data: customer_param
      )
      request.done (data, textStatus, jqXHR) ->
        Materialize.toast("Customer Create successfully.", 2000)
        $("#bill_update_#{bill_id}").prop('disabled', false)
        $(".customer_id_#{bill_id}").val(data.id)
        $(".profile_id_#{bill_id}").val(data.profile.id)
        $("#create_customer_#{bill_id}").hide()
        $("#update_customer_#{bill_id}").show()
      request.error (jqXHR, textStatus, errorThrown) ->
        console.log textStatus
        Materialize.toast("#{textStatus}", 5000)
        return    
    return  

  $(document).on "click", ".update_customer", ->
    bill_id = $(this).data("bill-id")
    customer_id = $(".customer_id_#{bill_id}").val()
    email = $(".customer_email_#{bill_id}").val()
    profile_id = $(".profile_id_#{bill_id}").val()
    mobile_no = $(".customer-mobile-no").val()
    name = $(".customer_name_#{bill_id}").val()
    if name == "" 
      Materialize.toast("Oops! Name can't blank.", 3000,'round')
    else if mobile_no == ""
      Materialize.toast("Oops! Mobile No can't blank.", 3000,'round')
    else if mobile_no.length < 10
      Materialize.toast("Oops! Contact No Must be 10 digit.", 3000,'round')  
    else
      customer_param = { "customer" : { "email" : "#{email}", "mobile_no" : "#{mobile_no}", "customer_profile_attributes" : { "customer_name" : "#{name}", "contact_no" : "#{mobile_no}", "id" : "#{profile_id}" } } }
      request = undefined
      request = $.ajax(
        type: 'POST',
        headers: {"X-HTTP-Method-Override": "PUT"},
        url: "/customers/"+customer_id,
        data: customer_param
      )
      request.done (data, textStatus, jqXHR) ->
        Materialize.toast("Customer Updated successfully.", 2000)
        $("#bill_update_#{bill_id}").prop('disabled', false)
        $("#create_customer_#{bill_id}").hide()
        $("#update_customer_#{bill_id}").show()
      request.error (jqXHR, textStatus, errorThrown) ->
        Materialize.toast("#{textStatus}", 5000)
        return
    return   

  $(document).on "click", ".split-bill-settlement-link", ->
    action = $(this).data("action")
    bill_id = $(this).data("bill-id")
    currency = $(this).data("currency") 
    split_bill_id = $(this).data("bill-split-id") 
    split_bill_amount = $(this).data("split-bill-amount")
    get_split_bill_details(bill_id,currency,action,split_bill_id,split_bill_amount)
    return

  # Generic function to get bill details
  get_split_bill_details = (bill_id,currency,action,split_bill_id,split_bill_amount) ->
    # preloader
    loader_data = {loader_type: 'color-spinner'}
    loader = JST['templates/loader'](loader_data)
    $("#bill_quickinfo_#{bill_id}").html loader      
    # Getting data through AJAX
    request = $.ajax(
      type: 'GET'
      url: "/api/v2/bills/#{bill_id}.json"
      dataType: "json"
    )
    request.done (responseData, textStatus, jqXHR) ->
      # Materialize.toast("#{responseData.messages.simple_message}", 5000)
      data = responseData.data
      $(".bill_grand_total_#{bill_id}").html data.grand_total
      status_content = get_bill_status(data.status)
      $(".bill_status_#{bill_id}").html status_content
      data.response = data
      data.currency = currency
      data.action = action
      data.split_bill_id = split_bill_id
      data.split_bill_amount = split_bill_amount
      result = JST["templates/bills/quick_details"](data)
      $("#bill_quickinfo_#{bill_id}").html result  
      $(".nc-actions").hide()
      $(".bill_remarks").hide()
      $(".bill_split").hide()
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      $("#bill_quickinfo_#{bill_id}").html textStatus
      return
    return   

  #Split bill settlement
  $(document).on "click", ".split_bill_settlement", ->
    bill_id = $(this).data("bill-id")   
    split_bill_id = $(this).data("bill-split-id") 
    payable_amount = $(this).data("split-bill-amount")    
    currency = $(this).data("currency")
    client_id = $(".current_user_id").val()
    action = 'view_bill'
    email_id = $(".current_user_email").val()
    device_id = 'YOTTO05'
    client_type = 'User'  
    settled_amount = 0
    payment_data = new Array
    $("input[name='split_settlement_mode_#{split_bill_id}']:checked").each ->
      payment_mode = $(this).val()
      if payment_mode is "cash"
        cash_amount = parseFloat($(".amount_cash_#{split_bill_id}").val())
        arr = {}
        arr =
          paymentmode_type : 'Cash'
          paymentmode_attributes :
            amount          : cash_amount
            balance_return  : 0
            tendered_amount : cash_amount
        payment_data.push arr
        settled_amount += cash_amount
      else if payment_mode is "card"
        card_amount = parseFloat($(".amount_card_#{split_bill_id}").val())
        card_no = $(".card_no_#{split_bill_id}").val()
        card_type = $(".card_type_#{split_bill_id}").val()
        card_mach = $(".merchandiser_#{split_bill_id}").val()
        arr = {}
        arr =
          paymentmode_type : 'card'
          paymentmode_attributes :
            no           : card_no
            valid_upto   : null
            card_type    : card_type
            bank         : null
            cvv          : null
            merchandiser : card_mach
            name_on_card : null
            amount       : card_amount
        payment_data.push arr
        settled_amount += card_amount
      return 
    if settled_amount != payable_amount
      Materialize.toast("Oops! payable amount and settled amount is not matching.", 3000,'round')
    else
      # API Call
      make_split_bill_settlement email_id, bill_id, client_id, client_type, device_id, payment_data, currency, split_bill_id, action
    return  
    return  

  make_split_bill_settlement = (email_id, bill_id, client_id, client_type, device_id, payment_data, currency, split_bill_id, action) ->
    settlement_request = $.ajax(
      type: 'POST'
      url: "/api/v2/settlements"
      dataType: "json"
      data:
        email           : email_id
        device_id       : device_id
        settlement_type : 'split'  
        settlement      :
          bill_id       : bill_id
          tips          : 0
          client_id     : client_id
          client_type   : client_type
          device_id     : device_id
          split_settlements_attributes : [{"bill_split_id": split_bill_id,"payments_attributes": payment_data}]
    ) 
    settlement_request.done (data, textStatus, jqXHR) ->
      if data.status is "ok"
        Materialize.toast(data.messages.internal_message, 2000)
        get_bill_details(bill_id,currency,action)
      else
        Materialize.toast(data.messages.internal_message, 2000)
    settlement_request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("#{textStatus}", 5000)
      return
    return    
    
  $(document).on "click", ".bill_settlement", ->
    bill_id = $(this).data("bill-id")
    payable_amount = $(this).data("bill-amount")
    currency = $(this).data("currency")
    current_user_id = $(".current_user_id").val()
    action = 'view_bill'
    payment_data = []
    amount = 0
    $("input[name='settlement_mode_#{bill_id}']:checked").each ->
      payment_mode = $(this).val()
      if payment_mode is "cash"
        cash_amount = parseFloat($(".amount_cash_#{bill_id}").val())
        arr = {}
        arr =
          payment_mode : 'cash'
          data :
            amount          : cash_amount
            balance_return  : 0
            denomination    : 0
            tendered_amount : cash_amount
        payment_data.push arr
        amount += cash_amount
      else if payment_mode is "card"
        card_no = $(".card_no_#{bill_id}").val()
        card_amount = parseFloat($(".amount_card_#{bill_id}").val())
        card_type = $(".card_type_#{bill_id}").val()
        card_mach = $(".merchandiser_#{bill_id}").val()

        arr = {}
        arr =
          payment_mode : 'card'
          data :
            no           : card_no
            valid_upto   : null
            card_type    : card_type
            bank         : null
            cvv          : null
            merchandiser : card_mach
            name_on_card : null
            amount       : card_amount
        payment_data.push arr
        amount += card_amount
      return
    if amount < payable_amount
      Materialize.toast("Sorry! amount in payment details(#{currency} #{amount}) is less than payable amount(#{currency} #{payable_amount}).", 5000)
    else if amount > payable_amount
      Materialize.toast("Sorry! amount in payment details(#{currency} #{amount}) is more than payable amount(#{currency} #{payable_amount}).", 5000)
    else
      settlement_data = {}
      settlement_data =
        status        : 'paid'
        bill_id       : bill_id
        bill_amount   : payable_amount
        tips          : 0
        client_id     : current_user_id
        client_type   : 'user'
        split_bill_id : null

      settlement_request = $.ajax(
        type: 'POST'
        url: "/settlements.json"
        dataType: "json"
        data:
          settlement : JSON.stringify(settlement_data)
          payments   : JSON.stringify(payment_data)
      )
      settlement_request.done (data, textStatus, jqXHR) ->
        if typeof data.error is 'undefined'
          Materialize.toast("Bill ID:#{bill_id} is successfully settled.", 5000)
          get_bill_details(bill_id,currency,action)
        else
          Materialize.toast("Sorry!! #{data.error}.", 5000)
      settlement_request.error (jqXHR, textStatus, errorThrown) ->
        Materialize.toast("#{textStatus}", 5000)
        return
      return
    return

  $(document).on "click", ".generate-invoice", (event) ->
    if ($(this).data("invoice-type") == "simple" )
      generate_invoice($(this).data("bill-id"), $(this).data("currency"), $(this).data("page-type"))
    else
      generate_way_invoice($(this).data("bill-id"), $(this).data("currency"), $(this).data("page-type"))      
    return

  
  generate_way_invoice = (bill_id,currency,page_type) ->
    request = $.ajax(
      type: 'GET'
      url: "/api/v2/bills/#{bill_id}"
      dataType: "json"
      data:
        resources: 'order_items,tax_details,discount_details,payment_details,delivery_details,unit_details'
    )
    request.done (data,textStatus,jqXHR) ->
      $("#wayinvoiceModalBody").html 'way bill representation'
      if page_type is 'a4'
        data.page_size= 640
      else if page_type is 'a5'
        data.page_size= 440
      else
        data.page_size= 540  
      amount = data.data.grand_total
      if `amount % 1 == 0`
          amount_in_word = convert_to_word(amount)+' Rupees only'
          data.amount_in_word =  amount_in_word
      else
        str = amount.toString()
        arr = str.split('.')
        string_amount = convert_to_word(Number(arr[0])) + ' Rupees and ' + convert_to_word(Number(arr[1])) + ' Paisa only'
        data.amount_in_word =  string_amount 

      data.response = data.data
      data.currency = currency
      data.action = "way_bill_invoice"
      invoice_result = JST["templates/pos/invoice"](data)
      $("#wayinvoiceModalBody").html invoice_result
    request.error (jqXHR, textStatus, errorThrown) ->
      console.log textStatus  
    #$("#wayinvoiceModalBody").html "<h1>way bill invoice operation is under progress </h1> bill id is=#{bill_id}"
    return 

  # Generate Invoice
  generate_invoice = (bill_id, currency, page_type) ->
    request = $.ajax(
      type: 'GET'
      url: "/api/v2/bills/#{bill_id}"
      dataType: "json"
      data:
        resources: 'order_items,tax_details,discount_details,payment_details,delivery_details,unit_details'
    )
    request.done (data, textStatus, jqXHR) ->
      console.log data
      $("#invoiceModalBody").html ''
      if page_type is 'a4'
        data.page_size= 640
      else if page_type is 'a5'
        data.page_size= 440
      else
        data.page_size= 540
      data.response = data.data
      data.currency = currency
      data.action = "simple_bill_invoice"
      invoice_result = JST["templates/pos/invoice"](data)
      $("#invoiceModalBody").html invoice_result
    request.error (jqXHR, textStatus, errorThrown) ->
      console.log textStatus
    return

  # Print function
  $(document).on "click", ".print", (event) ->
    #open new window set the height and width =0,set windows position at bottom
    a = window.open()
    #write gridview data into newly open window
    a.document.write document.getElementById('DivIdToPrint').innerHTML
    a.document.close()
    a.focus()
    #call print
    a.print()
    a.close()
    false
    return
    
  #print waybill
  $(document).on "click", ".print_way_bill", (event) ->
    #open new window set the height and width =0,set windows position at bottom
    a = window.open()
    #write gridview data into newly open window
    a.document.write document.getElementById('wayinvoiceModalBody').innerHTML
    a.document.close()
    a.focus()
    #call print
    a.print()
    a.close()
    false
    return

  $(document).on 'click', '.confirm-item', ->
    remarks = $("#return-remarks").val()
    selected_items = $("input:checkbox[name=return-product]:checked").length
    if remarks != "" && selected_items != 0
      $('.alert').hide()
      stock_decision = confirm "Do you want to add item in stock?"
      $.each $("input:checkbox[name=return-product]:checked"), ->
        bill_id = $(this).data("bill-id")
        order_detail_id = $(this).data("order-details-id")
        product_id = $(this).data("product-id")
        price = $(this).data("price")
        quantity = $(this).data("quantity")
        unit_id = $(this).data("unit-id")
        store_id = $(this).data("store-id")
        sku = $(this).data("sku")
        sell_price = $(this).data("sell-price")
        product_unit = $(this).data("product-unit")
        weight = $(this).data("weight")
        return_store_id = $(this).data("return-store-id")
        deliverable_id = $(this).data("deliverable-id")
        deliverable_type = $(this).data("deliverable-type")
        total_discount = $(this).data("discount")
        no_of_items = $(this).data("no-of-items")
        if stock_decision
          stock_status = "true"
        else
          stock_status = "false"  
        discount = total_discount / no_of_items
        return_price = sell_price - discount
        create_return_item_request = $.ajax (
          type: 'POST'
          url: "/return_items.json"
          dataType: "json"
          data:
            bill_id:            bill_id
            order_detail_id:    order_detail_id
            price:              price
            product_id:         product_id
            quantity:           quantity
            remarks:            remarks
            unit_id:            unit_id
            store_id:           return_store_id
            deliverable_id:     deliverable_id
            deliverable_type:   deliverable_type
            return_price:       return_price
            stock_status:       stock_status
        )
        create_return_item_request.done (data, textStatus, jqXHR) ->
          $(".return_items_status").html "<div class='alert m-alert-success padding-5'>Item Returned Successfully.</div>"
          $(".confirm-item").prop( "disabled", true );
        create_return_item_request.error (jqXHR, textStatus, errorThrown) ->
          $(".return_items_status").html "<div class='alert m-alert-success padding-5'>Error adding item to stock.</div>"
    else
      $(".return_items_status").html "<div class='alert m-alert-danger padding-5'>Please select minimum one item and give remarks.</div>"
    return


 
  convert_to_word = (amount) ->
    `var i`
    `var i`
    `var j`
    `var i`
    words = new Array
    words[0] = ''
    words[1] = 'One'
    words[2] = 'Two'
    words[3] = 'Three'
    words[4] = 'Four'
    words[5] = 'Five'
    words[6] = 'Six'
    words[7] = 'Seven'
    words[8] = 'Eight'
    words[9] = 'Nine'
    words[10] = 'Ten'
    words[11] = 'Eleven'
    words[12] = 'Twelve'
    words[13] = 'Thirteen'
    words[14] = 'Fourteen'
    words[15] = 'Fifteen'
    words[16] = 'Sixteen'
    words[17] = 'Seventeen'
    words[18] = 'Eighteen'
    words[19] = 'Nineteen'
    words[20] = 'Twenty'
    words[30] = 'Thirty'
    words[40] = 'Forty'
    words[50] = 'Fifty'
    words[60] = 'Sixty'
    words[70] = 'Seventy'
    words[80] = 'Eighty'
    words[90] = 'Ninety'
    amount = amount.toString()
    atemp = amount.split('.')
    number = atemp[0].split(',').join('')
    n_length = number.length
    words_string = ''
    if n_length <= 11
      n_array = new Array(0, 0, 0, 0, 0, 0, 0, 0, 0)
      received_n_array = new Array
      i = 0
      while i < n_length
        received_n_array[i] = number.substr(i, 1)
        i++
      i = 9 - n_length
      j = 0
      while i < 9
        n_array[i] = received_n_array[j]
        i++
        j++
      i = 0
      j = 1
      while i < 9
        if `i == 0` or `i == 2` or `i == 4` or `i == 7`
          if `n_array[i] == 1`
            n_array[j] = 10 + parseInt(n_array[j])
            n_array[i] = 0
        i++
        j++
      `value = ''`
      i = 0
      while i < 9
        if `i == 0` or `i == 2` or `i == 4` or `i == 7`
          `value = n_array[i] * 10`
        else
          `value = n_array[i]`
        if `value != 0`
          words_string += words[value] + ' '
        if `i == 1` and `value != 0` or `i == 0` and `value != 0` and `n_array[i + 1] == 0`
          words_string += 'Crores '
        if `i == 3` and `value != 0` or `i == 2` and `value != 0` and `n_array[i + 1] == 0`
          words_string += 'Lakhs '
        if `i == 5` and `value != 0` or `i == 4` and `value != 0` and `n_array[i + 1] == 0`
          words_string += 'Thousand '
        if `i == 6` and `value != 0` and `n_array[i + 1] != 0` and `n_array[i + 2] != 0`
          words_string += 'Hundred and '
        else if `i == 6` and `value != 0`
          words_string += 'Hundred '
        i++
      words_string = words_string.split('  ').join(' ')
      return words_string
    return

  return
