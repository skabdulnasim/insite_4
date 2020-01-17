# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  show_bill_suffix_and_prefix_limit = (key, con_value) ->
    if con_value == "enabled"
      display_action = "block"
    else
      display_action = "none"
    if key == "bill_suffix"
      $('.bill_suffix_limit').css("display",display_action)
    else
      $('.bill_prefix_limit').css("display",display_action)

  show_sku_algorithm = (key, con_value) ->
    if con_value == "enabled"
      display_action = "block"
    else
      display_action = "none"
    if key == "sku_algorithm"
      $('.sku_algo').css("display",display_action) 

  show_sku_algorithm_key = (key, con_value) ->
    if key == "uniqe_sku_for_stock"
      if con_value == "enabled"
        display_action = "none"
      else
        display_action = "block"
      $('.uniqe_stock_for_color_size').css("display",display_action) 
    if key == "uniqe_stock_for_color_size"
      if con_value == "enabled"
        display_action = "none"
      else
        display_action = "block"
      $('.uniqe_sku_for_stock').css("display",display_action)         

  show_sku_suffix_and_prefix_limit = (key, con_value) ->
    if con_value == "enabled"
      display_action = "block"
    else
      display_action = "none"
    if key == "sku_suffix"
      $('.sku_suffix_limit').css("display",display_action)
    else
      $('.sku_prefix_limit').css("display",display_action)    

  $(".update_app_config").each (index,obj) =>
    key = obj.getAttribute('data-conf-key')
    if obj.checked
      con_value = obj.getAttribute('data-value-active')
    else
      con_value = obj.getAttribute('data-value-inactive')
    #alert key  
    if key == "bill_suffix" || key == "bill_prefix"
      show_bill_suffix_and_prefix_limit(key, con_value) 
    if key == "sku_suffix" || key == "sku_prefix"
      show_sku_suffix_and_prefix_limit(key, con_value)
    if key == "sku_algorithm"
      show_sku_algorithm(key, con_value)
    if key == "uniqe_sku_for_stock"       
      show_sku_algorithm_key(key, con_value)
    if key == "uniqe_stock_for_color_size"       
      show_sku_algorithm_key(key, con_value)  

  $('.update_app_config').click ->
    key = $(this).attr('data-conf-key')
    active = $(this).attr('data-value-active')
    inactive = $(this).attr('data-value-inactive')
    container = $(this).attr('data-dependent-container')
    container = $("div[id$=#{container}]")
    con_value = if @checked then active else inactive
    request = $.ajax(
      type: 'POST'
      url: '/app_configurations/save_config'
      dataType: "json"
      data:
        config_key: key
        config_value: con_value
    )
    request.done (data, textStatus, jqXHR) ->
      if con_value == active then container.show() else container.hide()
      Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      if key == "bill_suffix" || key == "bill_prefix"
        show_bill_suffix_and_prefix_limit(key, con_value) 
      if key == "sku_suffix" || key == "sku_prefix"
        show_sku_suffix_and_prefix_limit(key, con_value) 
      if key == "sku_algorithm"
        show_sku_algorithm(key, con_value)  
      if key == "uniqe_sku_for_stock"       
        show_sku_algorithm_key(key, con_value)   
      if key == "uniqe_stock_for_color_size"       
        show_sku_algorithm_key(key, con_value)     
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "Error"
      return
    return


  
  $(document).on "click", ".user_target_role",->
    if $('.user_target_role:checkbox:checked').length > 1
      $(this).prop("checked", false);
      key = $(this).attr('data-conf-key')
      active = $(this).attr('data-value-active')
      inactive = $(this).attr('data-value-inactive')
      con_value = if @checked then active else inactive
      request = $.ajax(
        type: 'POST'
        url: '/app_configurations/save_config'
        dataType: "json"
        data:
          config_key: key
          config_value: con_value
      )
      request.done (data, textStatus, jqXHR) ->
        Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      request.error (jqXHR, textStatus, errorThrown) ->
        alert "Error"
        return
    return


  $('.update_app_text_config').change ->
    key = $(this).attr('data-conf-key')
    con_value = $(this).val()
    request = $.ajax(
      type: 'POST'
      url: '/app_configurations/save_config'
      dataType: "json"
      data:
        config_key: key
        config_value: con_value
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error", 5000)
      return
    return

  $('.update_account').change ->
    column_value = $(this).val()
    column_name = $(this).attr('data-column-name')
    request = $.ajax(
      type: 'POST'
      url: '/app_configurations/update_account'
      dataType: "json"
      data:
        column_name: column_name
        column_value: column_value
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Configuration parameter updated to: #{column_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("Error", 5000)
      return
    return

  $('.update_admin_email').change ->
    key = $(this).attr('data-conf-key')
    con_value = $(this).val()
    request = $.ajax(
      type: 'POST'
      url: '/app_configurations/save_config'
      dataType: "json"
      data:
        config_key: key
        config_value: con_value
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error", 5000)
      return
    return

  $('.update_urbanpiper_api_url').change ->
    key = $(this).attr('data-conf-key')
    con_value = $(this).val()
    request = $.ajax(
      type: 'POST'
      url: '/app_configurations/save_config'
      dataType: "json"
      data:
        config_key: key
        config_value: con_value
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error", 5000)
      return
    return

  $('.update_urbanpiper_api_username').change ->
    key = $(this).attr('data-conf-key')
    con_value = $(this).val()
    request = $.ajax(
      type: 'POST'
      url: '/app_configurations/save_config'
      dataType: "json"
      data:
        config_key: key
        config_value: con_value
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error", 5000)
      return
    return

  $('.update_zomato_api_key').change ->
    key = $(this).attr('data-conf-key')
    con_value = $(this).val()
    request = $.ajax(
      type: 'POST'
      url: '/app_configurations/save_config'
      dataType: "json"
      data:
        config_key: key
        config_value: con_value
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error", 5000)
      return
    return

  $('.update_urbanpiper_api_key').change ->
    key = $(this).attr('data-conf-key')
    con_value = $(this).val()
    request = $.ajax(
      type: 'POST'
      url: '/app_configurations/save_config'
      dataType: "json"
      data:
        config_key: key
        config_value: con_value
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error", 5000)
      return
    return

  $('.update_email_for_send_sale_details').change ->
    key = $(this).attr('data-conf-key')
    con_value = $(this).val()
    request = $.ajax(
      type: 'POST'
      url: '/app_configurations/save_config'
      dataType: "json"
      data:
        config_key: key
        config_value: con_value
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error", 5000)
      return
    return  

  $('.update_admin_email_password').change ->
    key = $(this).attr('data-conf-key')
    con_value = $(this).val()
    request = $.ajax(
      type: 'POST'
      url: '/app_configurations/save_config'
      dataType: "json"
      data:
        config_key: key
        config_value: con_value
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error", 5000)
      return
    return

  $('#printer_assignable_type').change ->
    listen()
    return

  listen = ->
    model_name = $('#printer_assignable_type').val()
    if model_name
      printer_id = $('#printer_id').val()
      if printer_id == ""
        printer_id = "NULL"
      $.get '/printers/model_data_list/'+printer_id+'/' + model_name, (data) ->
        contentStr = ""
        for i in [0..(data.length-1)]
          contentStr += "<input type='checkbox' id='assign_#{data[i].id}' name='assignable_id[]' value='#{data[i].id}'>"
          contentStr += "<label for='assign_#{data[i].id}'>#{data[i].name}</label>"
        $('#related_model_data').html contentStr
        return
    else
      $('#related_model_data').empty
    return

  $('.update_number_of_offline_orders').change ->
    key = $(this).attr('data-conf-key')
    con_value = $(this).val()
    request = $.ajax(
      type: 'POST'
      url: '/app_configurations/save_config'
      dataType: "json"
      data:
        config_key: key
        config_value: con_value
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error", 5000)
      return
    return

  $('.update_knowlarity_phone_no').change ->
    key = $(this).attr('data-conf-key')
    con_value = $(this).val()
    request = $.ajax(
      type: 'POST'
      url: '/app_configurations/save_config'
      dataType: "json"
      data:
        config_key: key
        config_value: con_value
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error", 5000)
      return
    return  

  $('.update_bill_suffix_limit').change ->
    key = $(this).attr('data-conf-key')
    con_value = $(this).val()
    request = $.ajax(
      type: "POST"
      url: '/app_configurations/save_config'
      dataType: "json"
      data:
        config_key: key
        config_value: con_value
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX error", 5000)
      return
    return

  $('.update_bill_preix_limit').change ->
    key = $(this).attr("data-conf-key")
    con_value = $(this).val()
    request = $.ajax(
      type: "POST" 
      url: "/app_configurations/save_config"
      dataType: "json"
      data:
        config_key: key
        config_value: con_value
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX error", 5000)
      return
    return

  $('.update_vtax_five_percent_limit').change ->
    key = $(this).attr('data-conf-key')
    con_value = $(this).val()
    request = $.ajax(
      type: 'POST'
      url: '/app_configurations/save_config'
      dataType: "json"
      data:
        config_key: key
        config_value: con_value
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error", 5000)
      return
    return  

  $('.update_report_precision').change ->
    key = $(this).attr('data-conf-key')
    con_value = $(this).val()
    request = $.ajax(
      type: 'POST'
      url: '/app_configurations/save_config'
      dataType: "json"
      data:
        config_key: key
        config_value: con_value      
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error", 5000)
      return    
    return

  $('.update_tally_company_name').change ->
    key = $(this).attr('data-conf-key')
    con_value = $(this).val()
    request = $.ajax(
      type: 'POST'
      url: '/app_configurations/save_config'
      dataType: "json"
      data:
        config_key: key
        config_value: con_value      
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error", 5000)
      return    
    return

  $('.update_tally_godown_name').change ->
    key = $(this).attr('data-conf-key')
    con_value = $(this).val()
    request = $.ajax(
      type: 'POST'
      url: '/app_configurations/save_config'
      dataType: "json"
      data:
        config_key: key
        config_value: con_value      
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error", 5000)
      return    
    return

  $('.update_tally_state_name').change ->
    key = $(this).attr('name')
    con_value = $(this).val()
    request = $.ajax(
      type: 'POST'
      url: '/app_configurations/save_config'
      dataType: "json"
      data:
        config_key: key
        config_value: con_value      
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Configuration parameter updated to: #{con_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error", 5000)
      return    
    return

  return
