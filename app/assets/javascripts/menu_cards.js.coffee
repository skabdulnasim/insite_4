# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  
  $(".clone-container").hide()

  $('.urbanpiper_product_up').on 'click', ->
    j = []
    checkboxes = document.getElementsByTagName('input')
    i = 0
    while i < checkboxes.length
      if checkboxes[i].type == 'checkbox' and checkboxes[i].name == 'toggle_mp_id[]' and checkboxes[i].checked == true
        j.push checkboxes[i].value
      i++
    document.getElementById('up_item_id').value = JSON.stringify(j)
    return

  $('.thirdparty_product_toggle').on 'click', ->
    j = []
    checkboxes = document.getElementsByTagName('input')
    i = 0
    while i < checkboxes.length
      if checkboxes[i].type == 'checkbox' and checkboxes[i].name == 'toggle_mp_id[]' and checkboxes[i].checked == true
        j.push checkboxes[i].value
      i++
    document.getElementById('toggle_outlet_item_id').value = JSON.stringify(j)
    document.getElementById('toggle_item_id').value = JSON.stringify(j)
    return

  $('.outlet_thirdparty_menu_up').on 'click', ->
    j = []
    checkboxes = document.getElementsByTagName('input')
    i = 0
    while i < checkboxes.length
      if checkboxes[i].type == 'checkbox' and checkboxes[i].name == 'toggle_mp_id[]' and checkboxes[i].checked == true
        j.push checkboxes[i].value
      i++
    document.getElementById("thirdparty_outlet_upload_menu_product_ids").value = JSON.stringify(j)
    return
    # 
    # menu_product_ids= j
    # request = $.ajax(
    #   type: 'GET'
    #   url: '/menu_products/thirdparty_item_action/'
    #   dataType: "json"
    #   data:
    #     menu_product_ids: menu_product_ids    
    # )
    # request.done (data, textStatus, jqXHR) ->
    #   item_action = true

    #   $.each data, (index, value) ->
    #     item_action = if value['action'] == "enable" then true else false
    #     return
    #   $('#toggle_thirdparty_item_action').prop 'checked', item_action
    # request.error (jqXHR, textStatus, errorThrown) ->
    #   alert "Error"
    #   return 
    # return

  # $('.toggle_mp_select_all').on 'click', ->
  #   if @checked
  #     $('.toggle_mp_class').each ->
  #       @checked = true
  #       return
  #   else
  #     $('.toggle_mp_class').each ->
  #       @checked = false
  #       return
  #   return
    
  # $('.toggle_mp_class').on 'click', ->
  #   if $('.toggle_mp_class:checked').length == $('.toggle_mp_class').length
  #     $('.toggle_mp_select_all').prop 'checked', true
  #   else
  #     $('.toggle_mp_select_all').prop 'checked', false
  #   return
  $('#menu_card_sort_items_by').on 'change', ->
    if $(this).val() != ""
      $('#sort_dtls').show()
    else
      $('#sort_dtls').hide()
      return
    return

  $(document).on "click", ".remove_fields", (event) ->
    $(this).closest('li').remove()
    event.preventDefault()    
    return

  $(document).on "click", ".add_fields", (event) ->
    time = new Date().getTime()
    console.log  time
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()

    # Setting parent attribute (only applicable for menu categories)
    parent_id = $(this).data('parent')
    console.log parent_id
    $("#menu_card_menu_categories_attributes_#{time}_parent").val(parent_id)    
    return

  $(document).on "click", ".update_menu_mode",->
    id = $(this).attr('data-id')
    active = $(this).attr('data-mode-active')
    inactive = $(this).attr('data-mode-inactive')
    mode_value = if @checked then active else inactive
    mode_message = if @checked then "active" else "inactive"
    request = $.ajax(
      type: 'GET'
      url: '/menu_cards/mode_toggle/'
      dataType: "json"
      data:
        id: id
        mode: mode_value      
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Menu card updated to: #{mode_message}", 5000)
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "Error"
      return    
    return

  $(".icon_add_item").on "click", ->
    value = $(this).attr('id')
    #alert value
    $("#menu_product_menu_card_id").val(value)
    return
  
  $(".variable").hide() 
  #$("#raw").hide()  

  $(".is_unit_currency_change").on "change", ->
    if $(this).val() == "Yes"
      $("#unit_currency_sale_price_"+$(this).data("menu-product-id")).show()
      $(".sell_price_wot_"+$(this).data("menu-product-id")).attr("readonly","readonly")
    else
      $("#unit_currency_sale_price_"+$(this).data("menu-product-id")).hide()
      $(".sell_price_wot_"+$(this).data("menu-product-id")).removeAttr("readonly")
      return
    return

  $(".sell_unit_currency_price_all_keyup").on "keyup", ->
    # alert $(this).data("menu-product-id")+" "+$(this).val()
    # alert $(this).data("unit-conversion_rate")
    # alert $(this).data("tax-rate")
    if $(this).val() > 0
      val_in_unit_curr_wt = $(this).val()
      conversion_rate = $(this).data("unit-conversion_rate")
      val_in_base_wt = conversion_rate * val_in_unit_curr_wt
      t_val = parseFloat($(this).data("tax-rate"))
      val_in_wot = ((val_in_base_wt*100)/(100+t_val))  #.toFixed(2)
      $(".sell_price_wot_"+$(this).data("menu-product-id")).attr("value", val_in_wot)
    else
      $(".sell_price_wot_"+$(this).data("menu-product-id")).attr("value", "0")
      return
    return

  $("#product_type").on "change", ->
    product_type = $("#product_type").val()
    #alert product_type
    if product_type == "variable"
      $("#menu_product_stock_qty").val(0)
      $('#menu_product_stock_qty').attr("disabled","disabled")
      $(".simple").hide()
      $(".combo").hide()
      $(".variable").show()
      $('#menu_product_store_id').prop('required', false)
      $('#menu_product_store_id').show()
      return
    if product_type == "simple"
      $(".variable").hide()
      $(".combo").hide()
      $(".simple").show()
      $('#menu_product_store_id').prop('required', true)
      $('#menu_product_store_id').show()
      return 
    if product_type == "combo"
      $(".variable").hide()
      $(".simple").hide()
      $(".combo").show()
      $('#menu_product_store_id').prop('required', true)
      return 
    return 
####################################################################################################################################    
######################################### To copy one a menu-card to anather blank menu-card########################################
    
  $(".icon_copy").on "click", ->
    #alert "hi"
    copy_from_id = $("#sel_menu").val()
    copy_to_id = $(this).attr("id")
    #alert copy_from_id
    #alert copy_to_id
    #alert menu_id
    request = undefined
    request = $.ajax(url: "/menu_products/copy_menu/?copy_from_id="+copy_from_id+"&copy_to_id="+copy_to_id) 
    request.done (data, textStatus, jqXHR) ->
      #console.log data
      alert "You have successfully copied this menu-card."
      location.reload(true)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "AJAX Error:" + textStatus
      return 
    return
####################################################################################################################################
  $(".icon_sc").hide()
  $(".icon_fc").on "click", ->
    $(".icon_fc").hide()
    $(".icon_sc").show()
    #alert "hi"
    ul = $(this).closest("ul")
    ul.animate
      width: "+=25%"
    , "slow"
    return
  $(".icon_sc").on "click", ->
    $(".icon_sc").hide()
    $(".icon_fc").show()
    #alert "hi"
    ul = $(this).closest("ul")
    ul.animate
      width: "-=25%"
    , "slow"
    return
##########################################################################################################
#################################### Tax calculation on penu product add page ###############################
  cess_tax_on = undefined
  ##### if it is fron menu product edit form.....
  if $("#cess_tax_on_amnt_field").val()
    cess_tax_on = $("#cess_tax_on_amnt_field").val()
  ##### else it will be fron menu product create form.....
  else
    $("#simple_tax_amnt_field").val(0)
    $("#cess_tax_amnt_field").val(0)
    $("#tax_amnt_field").val(0)
    $(".tax_amnt").on "click", ->
      #alert "hi"
      $("#menu_product_sell_price_without_tax").val("")
      $("#menu_product_sell_price").val("")
      tax = $(this).attr('id')
      #alert tax
      tax_arr = tax.split(',')
      $("#simple_tax_amnt_field").val(tax_arr[0])
      $("#cess_tax_amnt_field").val(tax_arr[1])
      #cess_tax_on = parseFloat(tax_arr[2])
      cess_tax_on = parseFloat(tax_arr[2])
      return
    
  $("#menu_product_sell_price_without_tax").on "keyup", ->
    #alert "hi"
    simple_tax_per = parseFloat($("#simple_tax_amnt_field").val())
    cess_tax_per = parseFloat($("#cess_tax_amnt_field").val())
    #alert cess_tax_per
    before_sell = parseFloat($("#menu_product_sell_price_without_tax").val())
    #alert before_sell
    simple_tax_amnt = parseFloat(before_sell*simple_tax_per/100)
    #alert simple_tax_amnt

    ############## currently off for tax group #############
    #cess_tax_amnt_on = parseFloat(before_sell*cess_tax_on/100)
    cess_tax_amnt_on = parseFloat(0)
    #alert cess_tax_amnt_on
    cess_tax_amnt = parseFloat(cess_tax_amnt_on*cess_tax_per/100)
    
    sell_price = parseFloat(before_sell)+simple_tax_amnt+cess_tax_amnt
    $("#menu_product_sell_price").val(0)
    $("#menu_product_sell_price").val(sell_price)
    return
#####################################################################################################
  
  $(".assign_to_unit").on "click", ->
    $("#from_menu_id").val($(this).attr('from_menu_id')) 
    $('input[name="section_id[]"]:checked').attr('checked', false)
    return
  

  $(".plus").on "click", ->
    $(".parent_val").val(this.id)
    return

  $(".change-tax-group").on "change", ->
    tax = $(this).find(':selected').attr('data-tax')
    $("#simple_tax_amnt_field").val(tax)
    $("#cess_tax_amnt_field").val(0)    
    return    

  $(document).on "click", ".showAddonModal",->
    $('#addonsModal').modal 'show'

  # Function to add products to temporary cart with quantity for adding them to a catalog
  $(document).on "click", ".add-product-to-menu",->
    product_id = $(this).data("product-id")
    product_business_type = $(this).data("product-btype")
    item_name = $(this).data("product-name")
    menu_id = $(this).data("menu-id")
    unit_id = $(this).data("unit-id")
    inventory_status = $(this).data("inventory-status")
    menu_product_type = $(".mproduct_type").val()
    if $("#cart_item_#{product_id}").length
      Materialize.toast("#{item_name} already selected.", 3000, 'rounded')
    else
      # Fetching unit data

      request_cost_categories = $.ajax(
        type: 'GET'
        url: "/api/v2/cost_categories"
        dataType: "json"
        data:
          resources: 'sections,stores,sorts,tax_groups,bill_destinations'
      )     
      request_cost_categories.done (costCategoryData, textStatus, jqXHR) -> 
        if costCategoryData.status is "error"
          Materialize.toast(costCategoryData.messages.internal_message, 5000, 'rounded')
        else
          # alert JSON.stringify(costCategoryData)
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
                url: "/api/v2/menu_cards/#{menu_id}"
                dataType: "json"
                data:
                  resources: 'categories'
              )     
              menu_request.done (menuData, textStatus, jqXHR) ->   
                if menuData.status is "error"
                  Materialize.toast(menuData.messages.internal_message, 5000, 'rounded')
                else
                  productData =
                    product_id:   product_id
                    product_name: item_name            
                    menu_card: menuData.data
                    unit_data: unitData.data
                    cost_category_data: costCategoryData.data
                    inventory_status: inventory_status
                    product_business_type: product_business_type
                    menu_product_type: menu_product_type
                  result = JST["templates/menu_cards/add_new_product"](productData)
                  console.log menuData.data
                  $(".no-item-selected").hide()
                  $(".menu-product-list").append(result)
                  Materialize.toast("#{item_name} selected.", 3000)
                return
              menu_request.error (jqXHR, textStatus, errorThrown) ->
                Materialize.toast("Something went wrong, please try after sometime.", 5000)
                return 
      # request.error (jqXHR, textStatus, errorThrown) ->
      request_cost_categories.error (jqXHR, textStatus, errorThrown) ->
        Materialize.toast("Something went wrong, please try after sometime.", 5000)
        return            
    return

  # Event handling on addon link click
  $(document).on "click", ".showAddonModal",->
    master_product_id = $(this).attr("data-master-product-id")
    master_key = $(this).attr("data-master-product-key")
    $("#addon_master_id").val(master_product_id)
    $("#addon_master_key").val(master_key)
    $(".addon-product-list").html('')
    return

  $(document).on "click", ".showComboItemsModal",->
    master_product_id = $(this).attr("data-master-product-id")
    master_key = $(this).attr("data-master-product-key")
    master_product_name = $(this).attr("data-master-product-name")
    $("#add_combo_item_to_mp").attr("data-master-product-id",master_product_id)
    $("#add_combo_item_to_mp").attr("data-master-product-key",master_key)
    $(".total_sp").attr("id","total_sp_#{master_product_id}")
    $(".remaining_sp").attr("id","remaining_sp_#{master_product_id}")
    total_sell_price = $(".sell_price_combo_product_#{master_product_id}").val()
    $("#total_sp_#{master_product_id}").html "#{master_product_name}: #{total_sell_price} Rs."
    $("#comboItemsModalLabel").html $(this).attr('data-master-product-name')
    $(".combo-product-list").find('tr').remove()
    return

  # Function defined to select addon/customization items to temporary cart with quantity
  $(document).on "click", ".add-addon-product-to-menu",->
    product_id = $(this).attr("data-product-id")
    item_name = $(this).attr("data-product-name")
    product_unit_id = $(this).attr("data-product-unit")
    combination_types = $("#combination_types_data").val().split('~~~')
    if $("#addon_cart_item_#{product_id}").length
      Materialize.toast("#{item_name} already selected.", 3000, 'rounded')
    else    
      request = $.ajax(
        type: 'GET'
        url: "/product_units"
        dataType: "json"
        data:
          product_basic_unit_id: product_unit_id
      )
      request.done (data, textStatus, jqXHR) ->
        data.product_units = data
        data.product_id = product_id
        data.product_name = item_name
        data.combination_types = combination_types
        result = JST["templates/menu_cards/add_new_addon"](data)
        $(".addon-product-list").prepend result
        Materialize.toast("#{item_name} selected.", 3000)
        return
      request.error (jqXHR, textStatus, errorThrown) ->
        $("#bill_quickinfo_#{bill_id}").html textStatus
        return      
    return

  # Function defined to select customization items to a catalog item
  $(document).on "click", "#add_addon_to_item",->
    # $('.available-products:checkbox:checked').map ->
    master_product_id = $("#addon_master_id").val()
    master_key = $("#addon_master_key").val()
    combination_types = $("#combination_types_data").val().split('~~~')
    $(".addon_products").each (index) ->
      if ($(this).is ":checked")
        addon_id = $(this).val()
        unless $("#menu_addon_item_#{addon_id}_of_master_#{master_product_id}").length
          product_unit_type = $(".addon_quantity_type_#{addon_id}").val().split('___')
          type_id = $(".addon_type_#{addon_id}").val()
          rule_id = $("#combination_rule_#{type_id}").val()
          data=
            master_product_key: master_key
            master_product_id: master_product_id
            addon_product_id: addon_id
            addon_product_name: $(".addon_name_#{addon_id}").val()
            addon_product_price: $(".addon_price_#{addon_id}").val()
            addon_product_quantity: $(".addon_quantity_#{addon_id}").val()
            addon_product_quantity_type: product_unit_type[0]
            addon_product_quantity_type_name: product_unit_type[1]
            addon_product_type: type_id
            addon_product_rule_id: rule_id
            combination_types: combination_types
          result = JST["templates/menu_cards/set_new_addon"](data)
          $(".selected-addon-container-#{master_product_id}").prepend result
    return

  # Function defined to select combo items to temporary cart with quantity
  $(document).on "click", ".add-combo-item-to-combo-product",->
    product_id = $(this).attr("data-product-id")
    item_name = $(this).attr("data-product-name")
    product_basic_unit_id = $(this).attr("data-product-basic-unit-id")
    combo_item_mp_id = $(this).attr("data-menu-product-id")
    master_product_id = $("#add_combo_item_to_mp").attr("data-master-product-id")
    # combination_types = $("#combination_types_data").val().split('~~~')
    if $("#combo_cart_item_#{product_id}_of_#{master_product_id}").length
      Materialize.toast("#{item_name} already selected.", 3000, 'rounded')
    else    
      discount = parseFloat($("#discount").val())
      email_id = $(".current_user_email").val()
      device_id = 'YOTTO05'
      request = $.ajax(
        type: 'GET'
        url: "/api/v2/products/get_colors_sizes"
        dataType: "json"
        data:
          email: email_id
          device_id: device_id
          product_basic_unit_id: product_basic_unit_id
          product_id: product_id
      )
      request.done (data, textStatus, jqXHR) ->
        data.product_units = data.data.product_units
        data.product_id = product_id
        data.product_name = item_name
        data.product_colors = data.data.colors
        data.product_sizes = data.data.sizes
        data.master_product_id = master_product_id
        result = JST["templates/menu_cards/add_new_combo_item"](data)
        $(".combo-product-list").prepend result
        Materialize.toast("#{item_name} selected.", 3000)
        return
      request.error (jqXHR, textStatus, errorThrown) ->
        $(".combo-product-list").html textStatus
        return      
    return

  # Function defined to select customization items to a catalog item
  $(document).on "click", "#add_combo_item_to_mp",->
    # $('.available-products:checkbox:checked').map ->
    master_product_id = $(this).attr("data-master-product-id")
    master_key = $(this).attr("data-master-product-key")
    email_id = $(".current_user_email").val()
    device_id = 'YOTTO05'
    $(".combo_items_product_#{master_product_id}").each (index) ->
      if ($(this).is ":checked")
        # :color_id, :item_id, :menu_product_id, :mode, :sell_price, :sell_price_without_tax, :size_id, :tax_group_id
        item_id = $(this).val()
        unless $("#menu_combo_item_#{item_id}_of_master_#{master_product_id}").length
          request = $.ajax(
            type: 'GET'
            url: "/api/v2/products/get_colors_sizes"
            dataType: "json"
            data:
              email: email_id
              device_id: device_id
              product_id: item_id
          )
          request.done (data, textStatus, jqXHR) ->
            combo_basic_unit = $(".combo_basic_unit_id_#{item_id}_of_#{master_product_id}").val().split('___')
            datalist=
              master_product_key: master_key
              master_product_id: master_product_id
              item_id: item_id
              combo_item_name: $(".combo_name_#{item_id}_of_#{master_product_id}").val()
              combo_sell_price: $(".combo_sell_price_#{item_id}_of_#{master_product_id}").val()
              combo_quantity: $(".combo_quantity_#{item_id}_of_#{master_product_id}").val()
              combo_basic_unit_id: combo_basic_unit[0]
              combo_basic_unit_name: combo_basic_unit[1]
              combo_size_id: $(".combo_size_#{item_id}_of_#{master_product_id}").val()
              combo_color_id: $(".combo_color_#{item_id}_of_#{master_product_id}").val()
              combo_color_name: $(".combo_color_#{item_id}_of_#{master_product_id} option:selected").text()
              combo_size_name: $(".combo_size_#{item_id}_of_#{master_product_id} option:selected").text()
              combo_sizes: data.data.sizes
              combo_colors: data.data.colors
            result = JST["templates/menu_cards/set_new_combo"](datalist)
            # $(".selected-addon-container-#{master_product_id}").prepend result
            $("#combo_items_of_#{master_product_id}").prepend result
    return

  $(document).on "keyup", ".combo_quantity", (event) ->
    master_product_id = $(this).attr('data-master-product-id')
    product_id = $(this).attr('data-product-id')
    quantity = $(this).val()
    if quantity.length > 0
      $(".combo_sell_price_#{product_id}_of_#{master_product_id}").attr('disabled',false)
    else
      $(".combo_sell_price_#{product_id}_of_#{master_product_id}").val('')
      $(".combo_sell_price_#{product_id}_of_#{master_product_id}").attr('disabled',true)
    return

  $(document).on "keyup", ".combo_item_sell_price", (event) ->
    master_product_id = $(this).attr("data-master-product-id")
    combo_total_sp = $(".sell_price_combo_product_#{master_product_id}").val()
    total_sell_price = 0
    $(".combo_items_product_#{master_product_id}").each ->
      if ($(this).is ":checked")
        product_id = $(this).attr("data-product-id")
        quantity = $(".combo_quantity_#{product_id}_of_#{master_product_id}").val()
        combo_item_sell_price = $(".combo_sell_price_#{product_id}_of_#{master_product_id}").val()
        combo_item_total_sell_price = quantity * combo_item_sell_price
        total_sell_price = total_sell_price + combo_item_total_sell_price
    if parseFloat(total_sell_price) != parseFloat(combo_total_sp)
      contentStr = "<div style='color:red;'>Sell price mismatched.</div>"
      $("#remaining_sp_#{master_product_id}").html contentStr
    else
      contentStr = "<div style='color:green;'>Sell price matched.</div>"
      $("#remaining_sp_#{master_product_id}").html contentStr
    return

  $(document).on "click", ".remove_all_combo_items", (event) ->
    combo_product_id = $(this).attr("data-combo-product-id")
    $("#combo_items_of_#{combo_product_id}").find("tr").remove()
    return

  $(document).on "click", ".remove_combo_item", (event) ->
    item_id = $(this).attr("data-combo-item-id")
    master_product_id = $(this).attr("data-master-product-id")
    $("#menu_combo_item_#{item_id}_of_master_#{master_product_id}").remove()
    return

  ########### Function to quick update menu products ###########
  $(document).on "click", ".update_menu_product",->
    id = $(this).data("id")
    name = $(this).data("product-name")
    mode = $(".mode_#{id}").find(':selected').val()
    tgid = $(".tax_group_#{id}").find(':selected').val()
    spwot = $(".sell_price_wot_#{id}").val() 
    pocp = $(".procure_price_#{id}").val()
    promo_id = $(".promo_code_#{id}").val()
    bill_destination_id = $(".bill_destination_#{id}").val()
    delivery_mode = $(".delivery_mode_#{id}").val()
    max_order_qty = $(".max_order_qty_#{id}").val()
    commission_capping_type = $(".commission_capping_type_#{id}").val()
    commission_capping = $(".commission_capping_#{id}").val()
    is_unit_currency = $(".is_unit_currency_#{id}").val()
    unit_currency_price = 0
    if is_unit_currency == "Yes"
      unit_currency_price = $(".sell_unit_currency_price_all_#{id}").val()
    request = $.ajax(
      type: 'POST'
      url: "/menu_products/#{id}/quick_update.json"
      dataType: "json"
      data:
        id: id
        mode: mode      
        tax_group_id: tgid
        sell_price_wot: spwot
        procured_price: pocp
        promo_id: promo_id
        bill_destination_id: bill_destination_id
        delivery_mode: delivery_mode
        max_order_qty: max_order_qty
        commission_capping_type: commission_capping_type
        commission_capping: commission_capping
        is_unit_currency: is_unit_currency
        unit_currency_price: unit_currency_price
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("#{name} successfully updated.", 5000)
      $(".sp_wot_#{id}").html(data.sell_price_without_tax)
      $(".sp_wt_#{id}").html(data.sell_price)
      $(".sp_wt_uc_#{id}").html(data.unit_currency_price)
      $(".last_up_#{id}").html(data.updated_at)
      if data.mode==1
        $("#product_header_#{id}").removeClass("orange white-text")
        $("#product_header_#{id}").addClass("light-blue light-blue-text text-lighten-5")
      else        
        $("#product_header_#{id}").removeClass("light-blue light-blue-text text-lighten-5")
        $("#product_header_#{id}").addClass("orange white-text")
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("Some error occured while updating menu product.", 5000)
      return  
    return 

  # Fetch details of section, branch and menu card for copy
  $(document).on "click", ".section_selector",->
    unit_id = $(this).data("unit-id")
    section_id = $(this).data("section-id")
    menu_id = $(".menu_card_id").val()
    $(".clone-container").hide()
    loader_data = 
      loader_type: "color-spinner"
    loader = JST['templates/loader'](loader_data)
    $('.menu_copy_container').html loader
    # Fetching unit data
    request = $.ajax(
      type: 'GET'
      url: "/api/v2/units/#{unit_id}"
      dataType: "json"
      data:
        resources: 'sections,stores,sorts,tax_groups'
    )
    request.done (unitData, textStatus, jqXHR) ->   
      if unitData.status is "error"
        Materialize.toast(unitData.messages.internal_message, 5000, 'rounded')
      else
        # Fetching menu card data
        menu_request = $.ajax(
          type: 'GET'
          url: "/api/v2/menu_cards/#{menu_id}"
          dataType: "json"
        )        
        menu_request.done (menuData, textStatus, jqXHR) ->   
          if menuData.status is "error"
            Materialize.toast(menuData.messages.internal_message, 5000, 'rounded')
          else
            $(".clone-container").show()
            # Setting hidden field data
            $(".target_section_id").val(section_id)
            $(".target_unit_id").val(unit_id)
            templateData =
              menu_card: menuData.data
              unit_data: unitData.data
              section_id: parseFloat(section_id)
            result = JST["templates/menu_cards/clone_menu"](templateData)
            $('.menu_copy_container').html result
          return
        menu_request.error (jqXHR, textStatus, errorThrown) ->
          Materialize.toast("Something went wrong, please try after sometime.", 5000)
          return 
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("Something went wrong, please try after sometime.", 5000)
      return
    return

  $(document).on "change", ".auto_populate_entity",->
    total_count = $(this).data('total-count')
    counter = $(this).data('counter')
    entity_type = $(this).data('entity-type')
    entity_value = $(this).val()
    while counter <= total_count-1
      $(".#{entity_type}_serial_#{counter} option[value=#{entity_value}]").prop('selected',true);
      counter++
    return

  $(document).on "change", ".mode_enable_disable",->
    lot_id =  $(this).attr('data-lot-id')
    menu_card_id = $(this).attr('data-menu-card-id')
    url = "/menu_cards/#{menu_card_id}/update_mode"
    request = $.ajax(
      type: 'POST'
      url: url
      data:
        lot_id: lot_id
    )
    request.done (data, textStatus, jqXHR) ->
      if data.mode==1
        Materialize.toast('Lot has been disabled',4000)
      else if data.mode==0
        Materialize.toast('Lot has been enabled',4000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error",4000)
      return
    
    return

  $(document).on "click", "#add_lot",->
    lot_id = $(this).attr('data-lot-id')
    $('#lot_id').val(lot_id)
    return

  $(document).on "click", ".menu_product_rule_add",->
    menu_product_id = $(this).data('menu-product-id')
    $('#menu_product_id').val(menu_product_id)
    request = $.ajax(
      type: 'GET'
      url: "/sale_rules/all_sale_rules"
      data:
        menu_product_id: menu_product_id
        sale_rule_types: 'specific,bill_buster'
        specific_type: 'by_product'
    )
    request.done (responseData, textStatus, jqXHR) ->
      responseData.sale_rules = responseData
      result = JST["templates/sale_rules/all_sale_rules_details"](responseData)
      $(".all_sale_rules").html result
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      $(".all_sale_rules").html "No sale rules."
      return
    return

  # Menu product Lot quickview action
  $(document).on "click", ".mp-lot-quick-overview", ->
    #$("#returnStoresModal").modal('hide')
    action = $(this).data("action")
    mp_lot_id = $(this).data("mp-lot-id")
    get_mp_lot_details(mp_lot_id,action)
    return

  # Generic function to get Menu product Lot details
  get_mp_lot_details = (mp_lot_id,action) ->
    # preloader
    loader_data = {loader_type: 'color-spinner'}
    loader = JST['templates/loader'](loader_data)
    $("#mp_lot_quickinfo_#{mp_lot_id}").html loader
    # Getting data through AJAX
    request = $.ajax(
      type: 'GET'
      url: "/api/v2/lots/#{mp_lot_id}.json"
      dataType: "json"
    )
    request.done (responseData, textStatus, jqXHR) ->
      data = responseData.data
      console.log data
      data.response = data
      result = JST["templates/lots/quick_details"](data)
      $("#mp_lot_quickinfo_#{mp_lot_id}").html result
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      $("#mp_lot_quickinfo_#{mp_lot_id}").html textStatus
      return
    return

  $(document).on "click", ".mp-rule-quick-overview", ->
    menu_product_id = $(this).data('menu-product-id')
    loader_data = {loader_type: 'color-spinner'}
    loader = JST['templates/loader'](loader_data)
    $("#mp_rule_collapse_#{menu_product_id}").html loader

    request = $.ajax(
      type: 'GET'
      url: "/api/v2/menu_cards/mp_sale_rules.json"
      dataType: "json"
      data:
        menu_product_id: menu_product_id
    )
    request.done (responseData, textStatus, jqXHR) ->
      data = responseData.data
      console.log data
      data.response = data
      result = JST["templates/menu_cards/mp_sale_rules_quick_details"](data)
      $("#mp_rule_collapse_#{menu_product_id}").html result
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      $("#mp_rule_collapse_#{menu_product_id}").html textStatus
      return

    return

  $(document).on "click", ".lot_sale_rule_delete", ->

    if !window.confirm('Are you sure to delete the sale rule of this lot?')
      return false

    lot_id = $(this).data("lot-id")
    sale_rule_id = $(this).data("sale-rule-id")
    request = $.ajax(
      type: 'PUT'
      url: "/lots/delete_lot_sale_rule/"
      data:
        lot_id: lot_id
        sale_rule_id: sale_rule_id
    )
    request.done (data, textStatus, jqXHR) ->
      $("#tbody_#{lot_id}").find("#lot_sale_rule_tr_#{lot_id}_#{sale_rule_id}").remove()
      Materialize.toast('Rule has been deleted',4000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error",4000)
      return
    return

  $(document).on "click", ".mp_sale_rule_delete", ->

    if !window.confirm('Are you sure to delete the sale rule of this menu product?')
      return false

    menu_product_id = $(this).data("menu-product-id")
    sale_rule_id = $(this).data("sale-rule-id")
    id = $(this).data("id")
    request = $.ajax(
      type: 'PUT'
      url: "/menu_products/delete_mp_sale_rule/"
      data:
        menu_product_id: menu_product_id
        sale_rule_id: sale_rule_id
    )
    request.done (data, textStatus, jqXHR) ->
      # $("#tbody_#{lot_id}").find("#lot_sale_rule_tr_#{lot_id}_#{sale_rule_id}").remove()
      $("#mp_sale_rule_tr_#{id}").remove()
      Materialize.toast('Rule has been deleted',4000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error",4000)
      return
    return

  $(document).on "click", ".lot_quick_update_btn", (event) ->
    event.preventDefault()
    lot_id = $(this).data('lot-id')
    sell_price = $("#sell_price_#{lot_id}").val()
    expiry_date = $("#expiry_date_#{lot_id}").val()
    mrp = $("#mrp_#{lot_id}").val()
    request = $.ajax(
      type: 'PUT'
      url: "/lots/lot_quick_update"
      data:
        lot_id: lot_id
        sell_price: sell_price
        expiry_date: expiry_date
        mrp: mrp
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast('Lot has been updated successfully',4000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error",4000)
      return
    return

######## change sale price by menu category ###########

  $(document).on "click", ".category_sale_price_btn", (event) ->
    menu_card_id = $("#menu_card_id").val()
    menu_category_id = $(this).data("menu-category-id")
    increase_by_sp = $(".increase_by_sp_#{menu_category_id}").val()
    decrease_by_sp = $(".decrease_by_sp_#{menu_category_id}").val()
    decrease_by_mrp = $(".decrease_by_mrp_#{menu_category_id}").val()
    request = $.ajax(
      type: 'PUT'
      url: "/menu_cards/sale_price_update_by_category"
      data:
        menu_card_id: menu_card_id
        menu_category_id: menu_category_id
        increase_by_sp: increase_by_sp
        decrease_by_sp: decrease_by_sp
        decrease_by_mrp: decrease_by_mrp
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Sale price of products under #{data.name} category have been updated",4000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error",4000)
      return
    return

  $(document).on "keyup", ".increase_by_sp", ->
    menu_category_id = $(this).data("menu-category-id")
    val = $(this).val()
    if val.length != 0
      $(".decrease_by_sp_#{menu_category_id}").prop("disabled",true)
    else
      $(".decrease_by_sp_#{menu_category_id}").prop("disabled",false)
    return

  $(document).on "keyup", ".decrease_by_sp", ->
    menu_category_id = $(this).data("menu-category-id")
    val = $(this).val()
    if val.length != 0
      $(".increase_by_sp_#{menu_category_id}").prop("disabled",true)
    else
      $(".increase_by_sp_#{menu_category_id}").prop("disabled",false)
    return

# brand name ##########################
  # required
  # $(document).on "click", ".brand_name_price_btn", (event) ->
  #   menu_card_id = $("#menu_card_id").val()
  #   brand_name = $(this).data("brand-name")
  #   increase_by = $(".brand_name_increase_by_#{brand_name}").val()
  #   decrease_by = $(".brand_name_decrease_by_#{brand_name}").val()
  #   request = $.ajax(
  #     type: 'PUT'
  #     url: "/menu_cards/sale_price_update_by_brand_name"
  #     datatype: "json"
  #     data:
  #       menu_card_id: menu_card_id
  #       brand_name: brand_name
  #       increase_by: increase_by
  #       decrease_by: decrease_by
  #   )
  #   request.done (data, textStatus, jqXHR) ->
  #     Materialize.toast("Sale price of products with brand name #{data.brand_name} have been updated"  ,4000)
  #     return
  #   request.error (jqXHR, textStatus, errorThrown) ->
  #     Materialize.toast("AJAX Error",4000)
  #     return
  #   return

  # $(document).on "keyup", ".brand_name_increase_by", ->
  #   brand_name = $(this).data("brand-name")
  #   val = $(this).val()
  #   if val.length != 0
  #     $(".brand_name_decrease_by_#{brand_name}").prop("disabled",true)
  #   else
  #     $(".brand_name_decrease_by_#{brand_name}").prop("disabled",false)
  #   return

  # $(document).on "keyup", ".brand_name_decrease_by", ->
  #   brand_name = $(this).data("brand-name")
  #   val = $(this).val()
  #   if val.length != 0
  #     $(".brand_name_increase_by_#{brand_name}").prop("disabled",true)
  #   else
  #     $(".brand_name_increase_by_#{brand_name}").prop("disabled",false)
  #   return


# brand name and category ######################

  $(document).on "click", ".brand_name_price_btn", (event) ->
    $('#spinnerDiv').spin
      lines: 12
      length: 5
      width: 7
      radius: 20
      color: '#000'
      speed: 1
      trail: 60
      shadow: true
    $('body').addClass('blur-body')
    menu_card_id = $("#menu_card_id").val()
    brand_name = $(this).data("brand-name")
    sp_increase_by_brand_name = $(".brand_name_increase_by_sp_#{brand_name}").val()
    sp_decrease_by_brand_name = $(".brand_name_decrease_by_sp_#{brand_name}").val()
    mrp_decrease_by_brand_name = $(".brand_name_decrease_by_mrp_#{brand_name}").val()
    request = $.ajax(
      type: 'PUT'
      url: "/menu_cards/sale_price_update_by_brand_name"
      data:
        menu_card_id: menu_card_id
        brand_name: brand_name
        sp_increase_by_brand_name: sp_increase_by_brand_name
        sp_decrease_by_brand_name: sp_decrease_by_brand_name
        mrp_decrease_by_brand_name: mrp_decrease_by_brand_name
    )
    request.done (data, textStatus, jqXHR) ->
      $("#spinnerDiv").spin(false)
      $('body').removeClass('blur-body')
      Materialize.toast("Sale price of products with brand name #{brand_name} have been updated"  ,4000)
      console.log data
      console.log data["0"]
      data.response = data["0"]
      result = JST["templates/menu_cards/changed_sell_price_of_lot"](data)
      $("#changedLotSellPriceModalTitle").html "Changed Sell Price of Lots ( #{brand_name} products)"
      if data["0"] != undefined
        $('#changedLotSellPriceDiv').html result
      else
        $('#changedLotSellPriceDiv').html "No lot has been reflected."
      $('#changedLotSellPriceModal').modal('show')
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error",4000)
      return
    return

  $(document).on "keyup", ".brand_name_increase_by_sp", ->
    brand_name = $(this).data("brand-name")
    val = $(this).val()
    if val.length != 0
      $(".brand_name_decrease_by_sp_#{brand_name}").prop("disabled",true)
      $(".brand_name_decrease_by_mrp_#{brand_name}").prop("disabled",true)
    else
      $(".brand_name_decrease_by_sp_#{brand_name}").prop("disabled",false)
      $(".brand_name_decrease_by_mrp_#{brand_name}").prop("disabled",false)
    return

  $(document).on "keyup", ".brand_name_decrease_by_sp", ->
    brand_name = $(this).data("brand-name")
    val = $(this).val()
    if val.length != 0
      $(".brand_name_increase_by_sp_#{brand_name}").prop("disabled",true)
      $(".brand_name_decrease_by_mrp_#{brand_name}").prop("disabled",true)
    else
      $(".brand_name_increase_by_sp_#{brand_name}").prop("disabled",false)
      $(".brand_name_decrease_by_mrp_#{brand_name}").prop("disabled",false)
    return

  $(document).on "keyup", ".brand_name_decrease_by_mrp", ->
    brand_name = $(this).data("brand-name")
    val = $(this).val()
    if val.length != 0
      $(".brand_name_increase_by_sp_#{brand_name}").prop("disabled",true)
      $(".brand_name_decrease_by_sp_#{brand_name}").prop("disabled",true)
    else
      $(".brand_name_increase_by_sp_#{brand_name}").prop("disabled",false)
      $(".brand_name_decrease_by_sp_#{brand_name}").prop("disabled",false)
    return


  # brand_name_with_category_price_btn
  $(document).on "click", ".brand_name_with_category_price_btn", (event) ->
    # $("#spinnerDiv").spin();
    # $('#spinnerDiv').spin
    #   lines: 12
    #   length: 5
    #   width: 7
    #   radius: 20
    #   color: '#000'
    #   speed: 1
    #   trail: 60
    #   shadow: true
    # $('body').not('.ring').addClass('blur-body')
    # $('body').addClass('blur-body')
    $('body').css('pointer-events','none')
    $('.ring').show()
    menu_card_id = $("#menu_card_id").val()
    brand_name = $(this).data("brand-name")
    menu_category_id = $(this).data("menu-category-id")
    sp_increase_by_brand_name_category = $(".brand_name_with_category_increase_by_sp_#{menu_category_id}_#{brand_name}").val()
    sp_decrease_by_brand_name_category = $(".brand_name_with_category_decrease_by_sp_#{menu_category_id}_#{brand_name}").val()
    mrp_decrease_by_brand_name_category = $(".brand_name_with_category_decrease_by_mrp_#{menu_category_id}_#{brand_name}").val()
    request = $.ajax(
      type: 'PUT'
      url: "/menu_cards/sale_price_update_by_brand_name_and_category"
      data:
        menu_card_id: menu_card_id
        brand_name: brand_name
        menu_category_id: menu_category_id
        sp_increase_by_brand_name_category: sp_increase_by_brand_name_category
        sp_decrease_by_brand_name_category: sp_decrease_by_brand_name_category
        mrp_decrease_by_brand_name_category: mrp_decrease_by_brand_name_category
    )
    request.done (data, textStatus, jqXHR) ->
      # $("#spinnerDiv").spin(false)
      $('.ring').hide()
      # $('body').removeClass('blur-body')
      $('body').css('pointer-events','all')
      Materialize.toast("Sale price of products with brand name #{brand_name} have been updated"  ,4000)
      console.log data["0"]
      data.response = data["0"]
      result = JST["templates/menu_cards/changed_sell_price_of_lot"](data)
      $("#changedLotSellPriceModalTitle").html "Changed Sell Price of Lots ( #{brand_name} products)"
      if data["0"] != undefined
        $('#changedLotSellPriceDiv').html result
      else
        $('#changedLotSellPriceDiv').html "No lot has been reflected."
      $('#changedLotSellPriceModal').modal('show')
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      $('.ring').hide()
      $('body').removeClass('blur-body')
      Materialize.toast("AJAX Error",4000)
      return
    return

  $(document).on "keyup", ".brand_name_with_category_increase_by_sp", ->
    brand_name = $(this).data("brand-name")
    menu_category_id = $(this).data("menu-category-id")
    val = $(this).val()
    if val.length != 0
      $(".brand_name_with_category_decrease_by_sp_#{menu_category_id}_#{brand_name}").prop("disabled",true)
      $(".brand_name_with_category_decrease_by_mrp_#{menu_category_id}_#{brand_name}").prop("disabled",true)
    else
      $(".brand_name_with_category_decrease_by_sp_#{menu_category_id}_#{brand_name}").prop("disabled",false)
      $(".brand_name_with_category_decrease_by_mrp_#{menu_category_id}_#{brand_name}").prop("disabled",false)
    return

  $(document).on "keyup", ".brand_name_with_category_decrease_by_sp", ->
    brand_name = $(this).data("brand-name")
    menu_category_id = $(this).data("menu-category-id")
    val = $(this).val()
    if val.length != 0
      $(".brand_name_with_category_increase_by_sp_#{menu_category_id}_#{brand_name}").prop("disabled",true)
      $(".brand_name_with_category_decrease_by_mrp_#{menu_category_id}_#{brand_name}").prop("disabled",true)
    else
      $(".brand_name_with_category_increase_by_sp_#{menu_category_id}_#{brand_name}").prop("disabled",false)
      $(".brand_name_with_category_decrease_by_mrp_#{menu_category_id}_#{brand_name}").prop("disabled",false)
    return

  $(document).on "keyup", ".brand_name_with_category_decrease_by_mrp", ->
    brand_name = $(this).data("brand-name")
    menu_category_id = $(this).data("menu-category-id")
    val = $(this).val()
    if val.length != 0
      $(".brand_name_with_category_increase_by_sp_#{menu_category_id}_#{brand_name}").prop("disabled",true)
      $(".brand_name_with_category_decrease_by_sp_#{menu_category_id}_#{brand_name}").prop("disabled",true)
    else
      $(".brand_name_with_category_increase_by_sp_#{menu_category_id}_#{brand_name}").prop("disabled",false)
      $(".brand_name_with_category_decrease_by_sp_#{menu_category_id}_#{brand_name}").prop("disabled",false)
    return



# add lot rule

  $(document).on "click", ".add_lot_rule", (event) ->
    menu_card_id = $("#menu_card_id").val()
    brand_name = $(this).data("brand-name")
    menu_category_id = $(this).data("menu-category-id")

    $('input[name="brand_name"]').val(brand_name)
    $('input[name="menu_category_id"]').val(menu_category_id)
    
    # $('.add_lot_with_brand_category').attr('data-brand-name', brand_name);
    # $('.add_lot_with_brand_category').attr('data-menu-category-id', menu_category_id);
    return

  # $(document).on "click", ".add_lot_with_brand_category", (event) ->
  #   menu_card_id = $("#menu_card_id").val()
  #   brand_name = $(this).data("brand-name")
  #   menu_category_id = $(this).data("menu-category-id")
  #   $('.select-order:checkbox:checked').map ->
  #     sale_rule = $(this).data("brand-name")

  #   request = $.ajax(
  #     type: 'POST'
  #     url: "/menu_cards/add_rule_with_category_and_brand"
  #     data:
  #       menu_card_id: menu_card_id
  #       brand_name: brand_name
  #       menu_category_id: menu_category_id
  #   )
  #   request.done (data, textStatus, jqXHR) ->
  #     Materialize.toast("Rules have been added successfully."  ,4000)
  #     return
  #   request.error (jqXHR, textStatus, errorThrown) ->
  #     Materialize.toast("AJAX Error",4000)
  #     return

    return

  return
