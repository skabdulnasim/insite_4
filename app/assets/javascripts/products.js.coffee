# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  # $('#menu_product_header').hide()

  # New codes for product module
  # Initializing the product form wizard
  $('#wizard_vertical').steps
    headerTag: 'h3'
    bodyTag: 'section'
    transitionEffect: 'fade'
    stepsOrientation: 'vertical'
    showFinishButtonAlways: true
    enableAllSteps: true
    onStepChanging: (event, currentIndex, newIndex) ->
      true  
    onFinished: (event, currentIndex) ->
      form = $('.generic_product_form')
      form.submit()
      return

  # Event to remove fields
  $(document).on 'click', 'form .remove_fields', (event)->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('.form-group').hide()
    event.preventDefault()

  $(document).on 'click', '.remove_product_images', (event)->
    if !window.confirm('Are you sure to delete the image?')
      return false
    product_image_id = $(this).data("product-image-id")
    if product_image_id != undefined
      request = $.ajax(
        type: 'POST'
        url: "/products/delete_product_image"
        dataType: "json"
        data:
          product_image_id: product_image_id
      )
      $(this).closest('.form-group').hide()
    event.preventDefault()

  $(document).on 'click', '.remove_color', (event)->
    $(this).closest('.form-group').hide()
    color_id = $(this).data("color-id")
    $("#cart_item_color_#{color_id}").remove()
    event.preventDefault() 

  $(document).on 'click', '.remove_processes', (event)->
    process_id = $(this).data("process-id")
    $("#cart_item_process_#{process_id}").remove()
    event.preventDefault() 

  $(document).on 'click', '.remove_products', (event)->
    product_id = $(this).data("product-id")
    main_product_id = $(this).data("main-product-id")
    if main_product_id != undefined
      request = $.ajax(
        type: 'POST'
        url: "/products/delete_composition"
        dataType: "json"
        data:
          main_product_id: main_product_id
          raw_product_id: product_id
      )
      $("#cart_item_#{product_id}").next().remove()
    $("#cart_item_#{product_id}").remove()
    event.preventDefault()

  $(document).on 'click', '.remove_vendor_products', (event)->
    vendor_id = $(this).data("vendor-id")
    vendor_product_id = $(this).data("vendor-product-id")
    if vendor_product_id != undefined
      request = $.ajax(
        type: 'POST'
        url: "/products/delete_vendor_product"
        dataType: "json"
        data:
          vendor_product_id: vendor_product_id
      )
      $("#cart_item_vendor_#{vendor_id}").next().remove()
    $("#cart_item_vendor_#{vendor_id}").remove()
    event.preventDefault()

  $(document).on 'click', '.remove_product_tags', (event)->
    tag_id = $(this).data("tag-id")
    product_tag_id = $(this).data("product-tag-id")
    if product_tag_id != undefined
      request = $.ajax(
        type: 'POST'
        url: "/products/delete_product_tag"
        dataType: "json"
        data:
          product_tag_id: product_tag_id
      )
      $("#cart_item_tag_#{tag_id}").next().remove()
    $("#cart_item_tag_#{tag_id}").remove()
    event.preventDefault()  

  $(document).on 'click', '.remove_menu_products', (event)->
    menu_product_id = $(this).data("menu-product-id")
    menu_card_id = $(this).data("menu-card-id")
    if menu_product_id != undefined
      request = $.ajax(
        type: 'POST'
        url: "/products/delete_menu_product"
        dataType: "json"
        data:
          menu_product_id: menu_product_id
      )
      $("#cart_item_menu_product_#{menu_card_id}").next().remove()
    $("#cart_item_menu_product_#{menu_card_id}").remove()
    event.preventDefault()

  # Event to add fields
  $(document).on "click", ".add_fields", (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()

  ################ Separator for old codes ################
  $(".valid_box").hide()
  $(".icon_date").on "click", ->
    $(".valid_box").show()
    $(".icon_date").hide()
    return
  $(".cancel").on "click", ->
    $(".valid_box").hide()
    $(".icon_date").show()
    return

  $(".check-new-product-tab").on "click", ->
    if $(this).data("link-type") == "raw"
      $("#raw_product_filter").show()
    else
      $("#raw_product_filter").hide()
    return     
  
  pt = $("#product_product_type").val()
  if pt == "simple"
    $("#product_attributes").hide()
  else
    $("#product_raws").hide()
    $("#product_advance").hide()
    $("#product_linked").hide()
  if pt == "combo"
    $("#product_raws").show()
    $("#product_advance").hide()
    $("#product_linked").hide()
    $("#product_attributes").hide()
####################################### different inpu for different product type######################################   

   
  $("#product_product_type").on "change", ->
    product_type = $("#product_product_type").val()
    # alert product_type
    if product_type == "variable"
      $("#product_attributes").show()
      $("#product_raws").hide()
      $("#product_advance").hide()
      $("#product_linked").hide()
      $('#new_product')[0].reset()
      $("#product_product_type").val("variable")
      return

    if product_type == "combo"
      $("#product_raws").hide()
      $("#product_advance").hide()
      $("#product_attributes").hide()
      $("#product_linked").hide()
      $('#new_product')[0].reset()
      $("#product_product_type").val("combo")
      return

    if product_type == "simple"
      $("#product_raws").show()
      $("#product_advance").show()
      $("#product_attributes").hide()
      $("#product_linked").show()
      $('#new_product')[0].reset()
      $("#product_product_type").val("simple")
      if $("#product_business_type option[value='sellable']").length == 0
        $("#product_business_type").append("<option value='sellable'>Sellable</option>")
        return 
      return 
    return
  $(".icon_reset").on "click", ->
    $('#new_product')[0].reset()
    return 
  
  $(document).on "click", ".attr_rm",->
    id = $(this).data("term-id")
    $( ".term_container_#{id}" ).remove();
    rm_attr(this)
    return
  
  $("#attribute_id").on "change", ->
    cvalue = $(this).val()
    ctext = $(this).find('option:selected').text()
    #alert ctext
    request = undefined
    request = $.ajax(url: "/term_attributes/get_terms/?id="+cvalue)
    request.done (data, textStatus, jqXHR) ->
      console.log data
      data.attrs = data
      data.cvalue = cvalue
      data.text = ctext
      data.cvalue = cvalue
      result = undefined
      item1 = $( "li.item-1" )[ 0 ]
      $( "#attr_set" ).find( "."+ctext ).remove()
      result = JST["templates/products/attrs_box"](data)
      $("#attr_set").append result
      $(".attr_rm").bind "click", ->
        rm_attr(this)
        return
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "AJAX Error:" + textStatus
      return
    return
  rm_attr = (el) ->
    id = $(el).attr('id')
    $("."+id).remove()
    return

  $("#product_parent").on "change", ->
    currentSelection = $(this).val()
    #alert currentSelection
    request = undefined
    request = $.ajax(url: "/products/get_all_attributes/?id="+currentSelection)
    request.done (data, textStatus, jqXHR) ->
      console.log data
      data.attributes = data
      result = JST["templates/products/attribute"](data)
      $("#variants_box").html(result)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "AJAX Error:" + textStatus
      return
    return

  $(document).on "change", "#product_basic_unit_id",->
    basic_unit_id =  $(this).val()
    if basic_unit_id > 0
      request = $.ajax(
        type: 'GET'
        url: "/product_units"
        dataType: "json"
        data:
          product_basic_unit_id: basic_unit_id
      )
      request.done (data, textStatus, jqXHR) ->
        console.log data
        data.response = data
        result = JST["templates/products/transaction_unit"](data)
        $("#product_unit_container").html result
        return
      request.error (jqXHR, textStatus, errorThrown) ->
        $("#bill_quickinfo_#{bill_id}").html textStatus
        return
    else
      $("#product_unit_container").html "" 
      return
    return

  ########### Function to add products to temporary cart ###########    
  $(document).on "click", ".check_input",->
    input_id = $(this).data("input-id")
    if (this.checked)
      $("#InputAmount_quantity"+input_id).prop('required', true)     
    else
      $("#InputAmount_quantity"+input_id).prop('required', false)
    return
  ########### Function to add products to temporary cart to allocate t unit###########
  $(document).on "click", ".select-unit-products",->
    $('.available-products:checkbox:checked').map ->
      product_id = @value
      item_name = $(this).data("product-name")      
      if $("#cart_item_#{product_id}").length
        Materialize.toast("#{item_name} already selected.", 3000, 'rounded')
      else
        # Materialize.toast("#{item_name} selected.", 3000, 'rounded')
        contentString = "<tr class='data-table__selectable-row' id='cart_item_#{product_id}'>"
        contentString += "<td>##{product_id}<input type='hidden' name='products[]' value='#{product_id}'></td>"
        contentString += "<td>#{item_name}</td>"
        contentString += "</tr>"
        $(".no-item-selected").hide()
        $(".unit-product-list").prepend(contentString)

      return
    return 

  ########### Function to add store to temporary cart ###########    
  $(document).on "click", ".branch_check",->
    unit_id = $(this).data("input-id")
    unit_name = $(this).next('label').text()
    if (this.checked)
      request = $.ajax
                  url: "/stores/?id="+unit_id
                  method: 'GET'
                  dataType: "json"
      request.done (data, textStatus, jqXHR) ->
        console.log data
        data.stores = data
        data.unit_id = unit_id
        data.unit_name = unit_name
        result = JST["templates/products/store"](data)
        $("#unit_store_container").append result
        return
      request.error (jqXHR, textStatus, errorThrown) ->
        alert "AJAX Error:" + textStatus
        return
    else
      $("#unit_#{unit_id}").remove()  
    return

  # Trigger to open modal
  $(document).on "click", ".edit_product_unit_link", ->
    $('#product_unit_edit_modal').openModal()
    return

  # Trigger to open modal
  $(document).on "click", ".edit_tax_class_link", ->
    $('#tax_class_edit_modal').openModal()
    return 
  
  # Trigger to open modal
  $(document).on "click", ".edit_product_basic_unit_link", ->
    $('#product_basic_unit_edit_modal').openModal()
    return   
 # Trigger to close new user form
  $(document).on "click", ".close-product_unit-form", ->
    $('#new_product_unit').hide();
    $('#new_product_unit_link').show();
    $('#product_unit_edit_modal').closeModal()      
    return   

  # Trigger to close new user form
  $(document).on "click", ".close-product-basic-unit-form", ->
    $('#new_product_basic_unit').hide();
    $('#new_basic_unit_link').show();
    $('#product_basic_unit_edit_modal').closeModal()      
    return

  ########### Function to add products to temporary cart ###########
  $(document).on "click", ".add-products-as-raw", (event) ->
    product_id = $(this).data("product-id")
    time = new Date().getTime()
    if $("#cart_item_#{product_id}").length
      alert "Product already selected."
    else
      data=
        product_id: product_id
        product_name: $(this).data("product-name")
        product_unit: $(this).data("product-unit")
        product_units: $(this).data("raw-units")
        key: "#{time}#{product_id}"
      result = JST["templates/products/composition"](data)
      $("#composition-container").append result
      # _.each units, (data, idx) ->
      #   console.log data[0]
      #   console.log data[1]
      #   contentString += "<option value='#{data[1]}'>#{data[0]}</option>"
      # contentString += "</select></td>"
      # contentString += "</tr>"
      # $(".no-item-selected").hide()
      # $(".raw-product-list").append(contentString)
    event.preventDefault()
    return

  ########### Function to add processes to temporary cart ###########
  $(document).on "click", ".add-processes-as-composition", (event) ->
    process_id = $(this).data("process-id")
    time = new Date().getTime()
    if $("#cart_item_process_#{process_id}").length
      alert "Process already selected."
    else
      data=
        process_id: process_id
        process_name: $(this).data("process-name")
        key: "#{time}#{process_id}"
      result = JST["templates/products/process_composition"](data)
      $("#process-composition-container").append result
    event.preventDefault()
    return

  ########### Function to add color to temporary cart ###########
  $(document).on "click", ".add-colors-to-product", (event) ->
    color_id = $(this).data("color-id")
    time = new Date().getTime()
    if $("#cart_item_color_#{color_id}").length
      alert "Color already selected."
    else
      data=
        color_id: color_id
        color_name: $(this).data("color-name")
        key: "#{time}#{color_id}"
      result = JST["templates/products/color"](data)
      $("#color-container").append result
    event.preventDefault()
    return  

  $('.update_color_product').click ->
    key = $(this).attr('data-conf-key')
    active = $(this).attr('data-value-active')
    inactive = $(this).attr('data-value-inactive')
    product_id = $(this).attr('data-product-id')
    color_id = $(this).attr('data-color-id')
    con_value = if @checked then active else inactive
    request = $.ajax(
      type: 'POST'
      url: '/products/product_color_update'
      dataType: "json"
      data:
        product_id: product_id
        color_id: color_id
        config_value: con_value
    )
    request.done (data, textStatus, jqXHR) ->
      if con_value == '1'
        con_value = 'Inactive'
      else
        con_value = 'Active'  
      Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "Error"
      return
    return  

  ########### Product size image remove ###########
  $(document).on "click", ".remove_product_size_image", (event) ->
    if !window.confirm('Are you sure to delete the image?')
      return false
    product_size_id = $(this).data("product-size-id")
    size_id = $(this).data("size-id")
    product_size_image_id = $(this).data("product-size-image-id")
    prent=$(this).parent().parent()
    if product_size_image_id != undefined
      time = new Date().getTime()
      request = $.ajax(
        type: 'POST'
        url: "/products/delete_product_size_image"
        dataType: "json"
        data:
          product_size_image_id: product_size_image_id
      )
      prent.html('<div style="margin-top:5px;" class="btn-primary btn-sm float-left">
        <span>Choose Front</span>
        <input type="hidden" name="product[product_sizes_attributes]['+time+'][id]" value="'+product_size_id+'">
        <input class="filestyle" type="file" name="product[product_sizes_attributes]['+time+'][product_size_images_attributes]['+time+'1][image]">
      </div>')
    return
    
  ########### Function to add size to temporary cart ###########
  $(document).on "click", ".add-sizes-to-product", (event) ->
    size_id = $(this).data("size-id")
    time = new Date().getTime()
    if $("#cart_item_size_#{size_id}").length
      alert "Size already selected."
    else
      data=
        size_id: size_id
        size_name: $(this).data("size-name")
        key: "#{time}#{size_id}"
      result = JST["templates/products/size"](data)
      $("#size-container").append result
    event.preventDefault()
    return 

  $('.update_product_size').click ->
    key = $(this).attr('data-conf-key')
    active = $(this).attr('data-value-active')
    inactive = $(this).attr('data-value-inactive')
    product_id = $(this).attr('data-product-id')
    size_id = $(this).attr('data-size-id')
    con_value = if @checked then active else inactive
    request = $.ajax(
      type: 'POST'
      url: '/products/product_size_update'
      dataType: "json"
      data:
        product_id: product_id
        size_id: size_id
        config_value: con_value
    )
    request.done (data, textStatus, jqXHR) ->
      if con_value == '1'
        con_value = 'Inactive'
      else
        con_value = 'Active'  
      Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "Error"
      return
    return
  ########### Function to add size to temporary cart ###########
  $(document).on "click", ".add-vendor-to-product", (event) ->
    size_id = $(this).data("vendor-id")
    time = new Date().getTime()
    if $("#cart_item_vendor_#{size_id}").length
      alert "Size already selected."
    else
      data=
        vendor_id: size_id
        vendor_name: $(this).data("vendon-name")
        key: "#{time}#{size_id}"
      result = JST["templates/products/vendor"](data)
      $("#vendor-container").append result
    event.preventDefault()
    return   

  ########### Function to add vendors to temporary cart ###########
  $(document).on "click", ".add-vendors-to-product", (event) ->
    vendor_id = $(this).data("vendor-id")
    time = new Date().getTime()
    if $("#cart_item_vendor_#{vendor_id}").length
      alert "Vendor already selected."
    else
      data=
        vendor_id: vendor_id
        vendor_name: $(this).data("vendor-name")
        key: "#{time}#{vendor_id}"
      result = JST["templates/products/vendor_product"](data)
      $("#vendor-container").append result
    event.preventDefault()
    return

  ########### Function to add vendors to temporary cart ###########
  $(document).on "click", ".add-tags-to-product", (event) ->
    tag_id = $(this).data("tag-id")
    time = new Date().getTime()
    if $("#cart_item_tag_#{tag_id}").length
      alert "Tag already selected."
    else
      data=
        tag_id: tag_id
        tag_name: $(this).data("tag-name")
        key: "#{time}#{tag_id}"
      result = JST["templates/products/product_tag"](data)
      $("#tag-container").append result
    event.preventDefault()
    return  


  ########### Function to add menu cards to temporary cart ###########
  $(document).on "click", ".add-products-to-menu-card", (event) ->
    menu_card_id = $(this).data("menu-card-id")
    menu_card_name = $(this).data("menu-card-name")
    time = new Date().getTime()
    unit_id = $(this).data("menu-unit-id")
    inventory_status = $(this).data("inventory-status")
    if $("#cart_item_menu_product_#{menu_card_id}").length
      alert "Menu card already selected."
    else
      request = $.ajax(
        type: 'GET'
        url: "/api/v2/units/#{unit_id}"
        dataType: "json"
        data:
          resources: 'sections,stores,sorts,tax_groups,bill_destinations'
      )
      request.done (unitData, textStatus, jqXHR) ->
        if unitData.status is "error"
          Materialize.toast(unitData.messages.internal_message, 5000, 'rounded')
        else
          # Fetching menu card data
          menu_request = $.ajax(
            type: 'GET'
            url: "/api/v2/menu_cards/#{menu_card_id}"
            dataType: "json"
            data:
              resources: 'categories'
          )
          menu_request.done (menuData, textStatus, jqXHR) ->
            if menuData.status is "error"
              Materialize.toast(menuData.messages.internal_message, 5000, 'rounded')
            else
              if menuData.data.categories.length > 0
                data=
                  menu_card_id: menu_card_id
                  menu_card_name: menu_card_name
                  key: "#{time}#{menu_card_id}"
                  inventory_status: inventory_status                
                  menu_card: menuData.data
                  unit_data: unitData.data
        
                result = JST["templates/products/menu_card_products"](data)
                if $("#menu_product_header").css('display') == 'none'
                  $('#menu_product_header').show()
                $("#menu-cards-container").append result
              else
                Materialize.toast("Add category before adding", 5000, 'red')
            return
        return
    event.preventDefault()
    return

  ############ Function to add process dependencies ############
  $(document).on "click", ".add_process_dependecy",->
    process_composition_id = $(this).data('process-composition-id')
    $('#process_composition_id').val(process_composition_id)
    return   

  ######### function to manipulate transaction_unit ############
  $(document).on "click",".transaction_unit" ,->
    if(this.checked)
      if($(this).attr("name") == "input_units[]")
        console.log($(this).val())
        $("#input_multiplier_#{$(this).val()}").attr("hidden",false)
      else
        $("#output_multiplier_#{$(this).val()}").attr("hidden",false)
    else
      if($(this).attr("name") == "input_units[]")
        $("#input_multiplier_#{$(this).val()}").attr("hidden",true)
        $("#input_multiplier_#{$(this).val()}").val("")
      else
        $("#output_multiplier_#{$(this).val()}").attr("hidden",true)
        $("#output_multiplier_#{$(this).val()}").val("")
    return
       
