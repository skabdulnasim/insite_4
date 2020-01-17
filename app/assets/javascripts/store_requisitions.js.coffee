# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  ############################################# Recurring task modal operations###############################################
  
  $('.summary-products').prop('disabled',true)

  ########### Function to send requisition ###########
  $(document).on "click", ".send_now_req",->
    requisition_id = $(this).attr('id')
    request = undefined
    request = $.ajax(url: "/store_requisitions/send_requisition/?id="+requisition_id)
    request.done (data, textStatus, jqXHR) ->
      #console.log data
      alert "You have successfully sent this requisition."
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "There was a problem while sending this requisition."
      return
    return

  $(".make_rec").on "click", ->
    req_id = $(this).attr('id')
    $("#requisition_id").val(req_id)
    return

  curr_value = $("input:radio[name=requisition_type]:checked").val()
  #alert value
  if curr_value == "delay"
    $(".recurring_req_details").hide()
    $(".delay_req_details").fadeIn("slow")
  if curr_value == "recurring"
    $(".delay_req_details").hide()
    $(".recurring_req_details").fadeIn("slow")

  $("input:radio[name=requisition_type]").on "click", ->
    value = $(this).val()
    #alert value
    if value == "delay"
      $(".recurring_req_details").hide()
      $(".delay_req_details").fadeIn("slow")
    if value == "recurring"
      $(".delay_req_details").hide()
      $(".recurring_req_details").fadeIn("slow")
    return

  $(".diff_time").hide()
  $(".same_time").show()
  $("#recurrance_type").on "change", ->
    recurrance_type = $("#recurrance_type").val()
    if recurrance_type == "same"
      $(".diff_time").hide()
      $(".same_time").show()
    if recurrance_type == "diff"
      $(".diff_time").show()
      $(".same_time").hide()
    return

  $(document).on "click", ".product-details",->
    product_id = $(this).data("product-id")
    store_id = $(this).data("store-id")
    basic_unit = $(this).data("basic-unit")
    rq_date = $(this).data("rq-date")
    # preloader
    loader_data = {loader_type: 'color-spinner'}
    loader = JST['templates/loader'](loader_data)
    $("#requ_quickinfo_#{product_id}").html loader
    request = $.ajax(url: "/store_requisitions/get_summary_details.json?product_id="+product_id+"&store_id="+store_id+"&rq_date="+rq_date)
    request.done (data, textStatus, jqXHR) ->
      data.attributes = data
      data.basic_unit = basic_unit
      console.log data
      result = JST["templates/stores/summary_details"](data)
      $("#requ_quickinfo_#{product_id}").html result
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "AJAX Error:" + textStatus
      return
      return

  # $(document).on "click", ".select-product-vendors",->
  #   $('.vendor-product :selected').map ->
  #     vendor_id = $(this).val()
  #     vendor_name = $(this).text()
  #     product_name = $(this).data("product-name")
  #     product_id = $(this).data("product-id")
  #     basic_unit = $(this).data("basic-unit")
  #     item_quantity = $(this).data("product-quantity")
  #     if $("#vendor_#{vendor_id}").length==0
  #       vendorStr = "<ul class='collection padding-10'><div id='vendor_#{vendor_id}' class='vendor'>#{vendor_name}<input type='hidden' name='vendor_id[]' id='vendor_id_#{vendor_id}' value='#{vendor_id}'/></div></ul>"
  #       $(".po-product-list").append(vendorStr)
  #     contentStr = "<li class='collection-item' id='product_li_#{product_id}'><div>"
  #     contentStr += "<input type='checkbox' class='filled-in' name='checked_product_#{vendor_id}[]' value='#{product_id}'/ id='product_#{product_id}' checked>"
  #     contentStr += "<label for='product_#{product_id}' class='font-sz-11'>#{product_name}</label>"
  #     contentStr += "<span class='secondary-content font-sz-11'><span id='item_qty_#{product_id}'>#{item_quantity}</span> #{basic_unit}</span>"
  #     contentStr += "<input type='hidden' name='quantity#{product_id}' value='#{item_quantity}' id='cart_item_#{product_id}'/>"
  #     contentStr += "</div></li>"
  #     $("#vendor_#{vendor_id}").append(contentStr)
  #   return
  #   return

  ############# Callback function for requisition details in Modal ###################
  $(document).on "click", ".view-recevd-req-details",->
    id = $(this).attr('data-req-log-id')
    current_store_id = $(this).attr('data-store-id')
    request = undefined
    request = $.ajax(url: "/api/v2/store_requisitions/get_requistion_deta?log_id="+id+"&store_id="+current_store_id)
    request.done (data, textStatus, jqXHR) ->
      console.log data
      data = data
      data.current_store = current_store_id
      result = undefined
      result = JST["templates/stores/requisition_details"](data)
      $("#showRequisitionModalDetails").html result
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "AJAX Error:" + textStatus
      return
    return

  $(document).on "change", ".vendor-product",->
    vendor_id = $(this).find("option:selected").val()
    vendor_name = $(this).find("option:selected").text()
    product_name = $(this).find("option:selected").data("product-name")
    product_id = $(this).find("option:selected").data("product-id")
    basic_unit = $(this).find("option:selected").data("basic-unit")
    item_quantity = $(this).find("option:selected").data("product-quantity")
    contentStr = "<li class='collection-item' id='product_li_#{product_id}'><div>"
    contentStr += "<input type='checkbox' class='filled-in' name='checked_product_#{vendor_id}[]' value='#{product_id}'/ id='product_#{product_id}' checked>"
    contentStr += "<label for='product_#{product_id}' class='font-sz-11'>#{product_name}</label>"
    contentStr += "<span class='secondary-content font-sz-11'><span id='item_qty_#{product_id}'>#{item_quantity}</span> #{basic_unit}</span>"
    contentStr += "<input type='hidden' name='quantity#{product_id}' value='#{item_quantity}' id='cart_item_#{product_id}'/>"
    contentStr += "</div></li>"

    if $("#product_li_#{product_id}").parent('div').parent('ul').children('div').children('li').length - 1==0
      $("#product_li_#{product_id}").parent('div').parent('ul').remove()

    if $("#vendor_#{vendor_id}").length
      $("#product_li_#{product_id}").remove()
      $("#vendor_#{vendor_id}").append(contentStr)
    else
      vendorStr = "<ul class='collection padding-10'><div id='vendor_#{vendor_id}' class='vendor'>#{vendor_name}<input type='hidden' name='vendor_id[]' id='vendor_id_#{vendor_id}' value='#{vendor_id}'/></div></ul>"
      $("#product_li_#{product_id}").remove()
      $(".po-product-list").prepend(vendorStr)
      $("#vendor_#{vendor_id}").append(contentStr)
    return

  $(document).on "keyup change", ".requ_quantity",->
    product_id = $(this).data("product-id")
    item_quantity = $(this).val()
    $("#item_qty_#{product_id}").html item_quantity
    return

  $(document).on "click", ".summary-products", ->
    po_or_requisition_production_selection = $("input:radio[name=select_po_or_requisition_or_production]:checked").val()
    product_id = $(this).data("product-id")
    product_name = $(this).data("product-name")
    basic_unit = $(this).data("basic-unit")
    item_quantity = $(this).data("product-quantity")

    if (this.checked)
      if po_or_requisition_production_selection != undefined
        $("#summary-container").removeClass('col-lg-12 col-sm-12')
        $("#summary-container").addClass('col-lg-8 col-sm-8')
        contentStr = "<li class='collection-item' id='li_product_#{product_id}'><div>"
        if po_or_requisition_production_selection == 'po_selected'
          contentStr += "<input type='checkbox' class='filled-in' name='checked_product[]' value='#{product_id}'/ id='product_#{product_id}' checked>"
        else if po_or_requisition_production_selection == 'requisition_selected'
          contentStr += "<input type='checkbox' class='filled-in' name='checked_raw[]' value='#{product_id}'/ id='product_#{product_id}' checked>"
        else if po_or_requisition_production_selection == 'production_selected'
          contentStr += "<input type='checkbox' class='filled-in' name='checked_raw[]' value='#{product_id}'/ id='product_#{product_id}' checked>"        
        contentStr += "<label for='product_#{product_id}' class='font-sz-11'>#{product_name}</label>"
        contentStr += "<span class='secondary-content font-sz-11'><span id='item_qty_#{product_id}'>#{item_quantity}</span> #{basic_unit}</span>"
        contentStr += "<input type='hidden' name='quantity_#{product_id}' value='#{item_quantity}' id='cart_item_#{product_id}'/>"
        contentStr += "</div></li>"
        
        if po_or_requisition_production_selection == 'po_selected'
          $("#product-container").removeClass('hidden')
          $("#product-container-for-requisition").addClass('hidden')
          $("#product-container-for-production").addClass('hidden')
          $(".no-item-selected").hide()
          $(".po-product-list").prepend(contentStr)
        else if po_or_requisition_production_selection == 'requisition_selected'
          $("#product-container").addClass('hidden')
          $("#product-container-for-requisition").removeClass('hidden')
          $(".no-requisition-item-selected").hide()
          $(".requisition-product-list").prepend(contentStr)
        else if po_or_requisition_production_selection == 'production_selected'
          $("#product-container").addClass('hidden')
          $("#product-container-for-production").removeClass('hidden')
          $(".no-production-item-selected").hide()
          $(".production-product-list").prepend(contentStr)

    else
      if po_or_requisition_production_selection == 'po_selected'
        $(".po-product-list").find("#li_product_#{product_id}").remove()
      else if po_or_requisition_production_selection == 'requisition_selected'
        $(".requisition-product-list").find("#li_product_#{product_id}").remove()
      else if po_or_requisition_production_selection == 'production_selected'
        $(".production-product-list").find("#li_product_#{product_id}").remove()

      if $('.summary-products:checked').length > 0
        if po_or_requisition_production_selection == 'po_selected'
          $("#product-container").removeClass('hidden')
        else if po_or_requisition_production_selection == 'requisition_selected'
          $("#product-container-for-requisition").removeClass('hidden')
        else if po_or_requisition_production_selection == 'production_selected'
          $(".product-container-for-production").removeClass('hidden')
        
      else
        $("#summary-container").removeClass('col-lg-8 col-sm-8')
        $("#summary-container").addClass('col-lg-12 col-sm-12')        
        $("#product-container").addClass('hidden')
        $("#product-container-for-requisition").addClass('hidden')
        $("#product-container-for-production").addClass('hidden')
        
    return

  $("input:radio[name=select_po_or_requisition_or_production]").on "change", ->
    $('.summary-products').prop('disabled',false)
    po_or_requisition_production_selection = $(this).val()
    $('.summary-products').prop('checked',false)
    $(".po-product-list").html ''
    $(".requisition-product-list").html ''
    $(".production-product-list").html ''
    $("#product-container").addClass('hidden')
    $("#product-container-for-requisition").addClass('hidden')
    $("#product-container-for-production").addClass('hidden')
    $("#summary-container").removeClass('col-lg-8 col-sm-8')
    $("#summary-container").addClass('col-lg-12 col-sm-12')
    return

  $(document).on "click", ".summary-raw-products", ->
    product_id = $(this).data("product-id")
    product_name = $(this).data("product-name")
    basic_unit = $(this).data("basic-unit")
    item_quantity = $(this).data("product-quantity")
    store_type = $("#store_type").val()

    if (this.checked)
      # if $("#open_modal").val()=="yes"
      #   $('#PoProductionSelectModal').modal('show')
      #   $("#open_modal").val("no")
      if store_type == 'kitchen_store'
        $("#raw-product-container-for-requisition").removeClass('hidden')
      else
        $("#raw-product-container").removeClass('hidden')

      # alert $("input:radio[name=select_po_or_production]:checked").val()

      # $("#raw-product-container-for-production").removeClass('hidden')

      # $("#summary-container").removeClass('col-lg-12 col-sm-12')
      # $("#summary-container").addClass('col-lg-7 col-sm-7')
      # $("#summary-container").removeClass('col-lg-6 col-sm-6')
      # $("#summary-container").addClass('col-lg-5 col-sm-5')
      $("#ingredients-container").removeClass('col-lg-12 col-sm-12')
      $("#ingredients-container").addClass('col-lg-8 col-sm-8')
      contentStr = "<li class='collection-item' id='li_raw_product_#{product_id}'><div>"
      if store_type == 'kitchen_store'
        contentStr += "<input type='checkbox' class='filled-in' name='checked_raw[]' value='#{product_id}'/ id='raw_product_#{product_id}' checked>"
      else
        contentStr += "<input type='checkbox' class='filled-in' name='checked_product[]' value='#{product_id}'/ id='raw_product_#{product_id}' checked>"
      contentStr += "<label for='raw_product_#{product_id}' class='font-sz-11'>#{product_name}</label>"
      contentStr += "<span class='secondary-content font-sz-11'><span id='raw_item_qty_#{product_id}'>#{item_quantity}</span> #{basic_unit}</span>"
      contentStr += "<input type='hidden' name='quantity#{product_id}' value='#{item_quantity}' id='raw_cart_item_#{product_id}'/>"
      contentStr += "</div></li>"
      if store_type == 'kitchen_store'
        $(".no-requisition-raw-item-selected").hide()
        $(".requisition-raw-product-list").prepend(contentStr)
      else
        $(".no-raw-item-selected").hide()
        $(".po-raw-product-list").prepend(contentStr)

      # production
      # $(".no-production-item-selected").hide()
      # $(".production-product-list").prepend(contentStr)

    else
      if store_type == 'kitchen_store'
        $(".requisition-raw-product-list").find("#li_raw_product_#{product_id}").remove()
      else
        $(".po-raw-product-list").find("#li_raw_product_#{product_id}").remove()

      # production
      # $(".production-product-list").find("#li_product_#{product_id}").remove()

      # if $('.checkbox-child:checked').length > 0
      if $('.summary-raw-products:checked').length > 0
        if store_type == 'kitchen_store'
          $("#raw-product-container-for-requisition").removeClass('hidden')
        else
          $("#raw-product-container").removeClass('hidden')

        # $("#product-container-for-production").removeClass('hidden')

      else
        # $("#summary-container").removeClass('col-lg-5 col-sm-5')
        # $("#summary-container").addClass('col-lg-6 col-sm-6')
        if store_type == 'kitchen_store'
          $("#raw-product-container-for-requisition").addClass('hidden')
        else
          $("#raw-product-container").addClass('hidden')

        # $("#product-container-for-production").addClass('hidden')

        $("#ingredients-container").removeClass('col-lg-8 col-sm-8')
        $("#ingredients-container").addClass('col-lg-12 col-sm-12')
        # $("#open_modal").val("yes")
    return



  $(document).on "change", "#req_date", ->
    $("#summary_req").submit()
    return

  #######################################################################################################################################
  #################################################### save recurring task using ajax ###################################################

  $(".save_recurring").on "click", ->
    requisition_id = $("#requisition_id").val()
    requisition_type = $("input:radio[name=requisition_type]:checked").val()
    #alert recurring_type

    if requisition_type == "delay"
      delayed_date = $("#delayed_date").val()
      delayed_time = $("#delayed_time").val()
      #alert delayed_date
      #alert delayed_time
      request = undefined
      request = $.ajax(url: "/store_requisitions/save_store_requisition/?id="+requisition_id+"&requisition_type=delay&delayed_date="+delayed_date+"&delayed_time="+delayed_time)
      request.done (data, textStatus, jqXHR) ->
        #alert "AJAX Success:" + textStatus
        location.reload(true)
        return
      request.error (jqXHR, textStatus, errorThrown) ->
        alert "There was a problem while recurring this requisition." + textStatus
        return

    if requisition_type == "recurring"
      if $("#recurrance_type").val() == "same"
        days = []
        $("input:checkbox[name=recurring_type]:checked").each ->
          days.push $(this).val()
          return
        #alert days
        time = $("#same_time").val()
        #alert time
        request = undefined
        request = $.ajax(url: "/store_requisitions/save_store_requisition/?id="+requisition_id+"&requisition_type=recurring&recurring_type=same&days="+days+"&times="+time)
        request.done (data, textStatus, jqXHR) ->
          #alert "AJAX Success:" + textStatus
          location.reload(true)
          return
        request.error (jqXHR, textStatus, errorThrown) ->
          alert "There was a problem while recurring this requisition." + textStatus
          return

      if $("#recurrance_type").val() == "diff"
        days = []
        times = []
        $("input:checkbox[name=recurring_type]:checked").each ->
          days.push $(this).val()
          times.push $("#"+$(this).val()).val()
          return
        #alert days
        #alert times
        request = undefined
        request = $.ajax(url: "/store_requisitions/save_store_requisition/?id="+requisition_id+"&requisition_type=recurring&recurring_type=diff&days="+days+"&times="+times)
        request.done (data, textStatus, jqXHR) ->
          #alert "AJAX Success:" + textStatus
          location.reload(true)
          return
        request.error (jqXHR, textStatus, errorThrown) ->
          alert "There was a problem while recurring this requisition." + textStatus
          return
    return

  ######################################################################################################################################
  ######################################### To copy prev requisition to a new one########################################

  $("#copy_req").on "change", ->
    #alert "hi"
    $('.panel_refresh').find('input:text').val('')
    $('.panel_refresh').find('input:checkbox').prop('checked', false)
    copy_from_id = $(this).val()
    #alert copy_from_id
    request = undefined
    request = $.ajax(url: "/store_requisitions/copy_requisition/?copy_from_id="+copy_from_id)
    request.done (data, textStatus, jqXHR) ->
      console.log data
      $.each data, ->
        aa = this.product_ammount
        bb = ".quantity"+this.product_id
        $(".quantity"+this.product_id).val(aa)
        $("#check"+this.product_id).prop('checked', true)
        return
      alert "You have successfully copied the requisition data."
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "AJAX Error:" + textStatus
      return
    return
####################################################################################################################################
  return
