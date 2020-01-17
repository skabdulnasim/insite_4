# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
  $(document).ready ->

    $("#add_to_stock_production_btn").prop('disabled', true)
    if $(".process_done_btn").length > 0 
      $("#finish_production_btn").prop("disabled",true)
  
  #Click on start stop button action
    $(".process_start_stop").change ->
      this_item = $(this)
      process_id =  $(this).attr('data-process-id')
      process_name = $(this).attr('data-process-name')
      store_id = $(this).attr('store_id')
      production_id= $(this).attr('production_id')
      menu_product_id = $(this).attr('data-menu-product-id')
      $("#process_complete_btn_id_#{menu_product_id}_#{process_id}").removeAttr('disabled')
      duration = $(this).attr('data-process-duration')
      key = $(this).attr('data-conf-key')
      active = $(this).attr('data-value-active')
      inactive = $(this).attr('data-value-inactive')
      process_status = if @checked then active else inactive
      stock_production_meta_id = $(this).attr('data-stock-production-meta-id')
      store_id = $("input[type='hidden'][name='stock_production[store_id]']").val()          
      process_width = $("#progressbar_inner_id_#{menu_product_id}_#{process_id}")[0].style.width
      if process_width==''
        process_width = '0%'
      if process_status==active
        if !window.confirm('Are you sure to start the process?')
          this_item.attr("checked",false)
          this_item.parent().parent().parent().find(".button_finish").attr("disabled",true)
          return false
      else if process_status==inactive
        if !window.confirm('Are you sure to stop the process?')
          this_item.prop("checked",true)
          return false
      process_composition_id = $(this).data('process-composition-id')
      url_check_process_dependency = "/stock_productions/check_process_dependency"
      request = $.ajax(
        type: 'GET'
        url: url_check_process_dependency
        data:
          process_composition_id: process_composition_id
          stock_production_meta_id: stock_production_meta_id
          target_product_id: menu_product_id
      )
      request.done (data, textStatus, jqXHR) ->
        console.log('status has been updated')
        if data.length > 0
          if data.length == 1
            Materialize.toast("#{data} has not completed yet.", 5000, "red")
          else
            Materialize.toast("#{data} have not completed yet.", 5000, "red")
          this_item.attr("checked",false)
          this_item.parent().parent().parent().find(".button_finish").attr("disabled",true)
        else
          url = "/stores/#{store_id}/stock_productions/stock_production_meta_process_update"
          request = $.ajax(
            type: 'PUT'
            url: url
            data:
              process_status: process_status
              stock_production_meta_id: stock_production_meta_id
              process_id: process_id
              process_width: process_width
          )
          request.done (data, textStatus, jqXHR) ->
            if (process_status==active)
              Materialize.toast("#{process_name} has been started", 2000)
              #progress bar calculation statrted
              width = parseInt(data.process_width)
              url_process_width = "/stores/#{store_id}/stock_productions/stock_production_meta_process_width_update"
              frame = ->
                $("#setIntervalId_#{menu_product_id}_#{process_id}").val(id)
                if width >= 100
                  clearInterval id
                  process_complete_toast_id = setInterval (->
                    Materialize.toast("#{process_name} has been completed. Please finish it.", 2000, "red")
                    return
                  ), 5000
                  $("#process_complete_toast_#{menu_product_id}_#{process_id}").val(process_complete_toast_id)
                else
                  width++
                  $("#process_complete_percentage_id_#{menu_product_id}_#{process_id}").html('(' + width + '%)')
                  $.ajax(
                    type: 'PUT'
                    url: url_process_width
                    data:
                      process_status: process_status
                      stock_production_meta_id: stock_production_meta_id
                      process_id: process_id
                      process_width: width + "%"
                  )
                  $("#progressbar_inner_id_#{menu_product_id}_#{process_id}").css({'width':width+ '%','background-color':'#54fa75','font-weight': 'bold'})
                return
              id = setInterval(frame, 600*duration)
            #progress bar calculation ended

            else if (process_status==inactive)
              Materialize.toast("#{process_name} has been stopped", 2000)
              $("#progressbar_inner_id_#{menu_product_id}_#{process_id}").css({'width':process_width,'background-color':'#54fa75','font-weight:bold;'})
              setIntervalId = $("#setIntervalId_#{menu_product_id}_#{process_id}").val()
              clearInterval setIntervalId
              process_complete_toast_id = $("#process_complete_toast_#{menu_product_id}_#{process_id}").val()
              clearInterval process_complete_toast_id
            return
          request.error (jqXHR, textStatus, errorThrown) ->
            Materialize.toast("AJAX Error", 5000)
            return
            return
        get_updated_status_url = "/stores/#{store_id}/stock_productions/get_production_status"
        console.log(production_id)
        console.log(stock_production_meta_id)
        get_updated_status = $.ajax(
          type: 'GET'
          url: get_updated_status_url
          data:
            meta_id: stock_production_meta_id
            production_id: production_id
        )
        get_updated_status.done (data, textStatus, jqXHR) ->
          $(".current_status").html data.status
          console.log(data)
          if data.status_code == '1'
            status = "<span class='label label-primary'>"+data.status+"</span>"
            $("#mystatus").html status
          else if data.status_code == '2'
            status = "<span class='label label-success'>"+data.status+"</span>"
            $("#mystatus").html status
          else if data.status_code == '3'
            status = "<span class='label label-warning'>"+data.status+"</span>"
            $("#mystatus").html status
          else
            status = "<span class='label label-danger'>"+data.status+"</span>"
            $("#mystatus").html status
          return
        get_updated_status.error ->
          alert 'some error occured in AJAX'
          return
      request.error (jqXHR, textStatus, errorThrown) ->
        Materialize.toast("AJAX Error", 5000)
        return
      return

  #Click on done button action
    $('.process_done_btn').click ->
      process_id =  $(this).attr('data-process-id')
      menu_product_id = $(this).attr('data-menu-product-id')
      
      process_id =  $(this).attr('data-process-id')
      stock_production_meta_id = $(this).attr('data-stock-production-meta-id')
      store_id = $("input[type='hidden'][name='stock_production[store_id]']").val()
      url = "/stores/#{store_id}/stock_productions/stock_production_meta_process_update"
      process_status = $(this).attr('data-process-status')

      if !window.confirm('Are you sure to finish the process?')
        return false

      if $(".process_done_btn").length == 1
        $("#finish_production_btn").prop("disabled",false)
      
      request = $.ajax(
        type : 'PUT'
        url : url
        data:
          process_status: process_status
          stock_production_meta_id: stock_production_meta_id
          process_id: process_id
      )
      request.done (data, textStatus, jqXHR) ->
        setIntervalId = $("#setIntervalId_#{menu_product_id}_#{process_id}").val()
        clearInterval setIntervalId
        process_complete_toast_id = $("#process_complete_toast_#{menu_product_id}_#{process_id}").val()
        clearInterval process_complete_toast_id
        $("#process_status_#{menu_product_id}_#{process_id}").html ""
        $("#process_status_#{menu_product_id}_#{process_id}").addClass('glyphicon glyphicon-ok m-btn green')  
        console.log data
        return
      request.error (jqXHR, textStatus, errorThrown) ->
        Materialize.toast("AJAX Error", 5000)
        return

      return

  ############ Add to stock button in stock production ##############
  $(document).on "click", ".checked_products", ->
    checked_products_length = $(".checked_products").filter(":checked").length
    if checked_products_length > 0
      $("#add_to_stock_production_btn").prop('disabled', false)
    else
      $("#add_to_stock_production_btn").prop('disabled', true)
    return

  $(document).on "click", ".checked_all_products", ->
    if (this.checked)
      $("#add_to_stock_production_btn").prop('disabled', false)
    else
      $("#add_to_stock_production_btn").prop('disabled', true)
    return

  $(document).on "click", ".print-barcodde",->
    sku = $(this).data('sku')
    name = encodeURI($(this).data('name'))
    site_name = $(this).data('site')
    count = $(this).data('count')
    mrp = if $(this).data('mrp') == null then "000000/-" else $(this).data('mrp')
    wt = if $(this).data('wt') == null then "0.0" else $(this).data('wt')
    mc = if $(this).data('mc') == null then "000000/-" else $(this).data('mc')
    wst = if $(this).data('wastage') == null then "0.0" else $(this).data('wastage')
    model_number = $(this).data('model-number')
    size = if $(this).data('size') == null then "-" else $(this).data('size')
    size = encodeURI(size)
    color_name = if $(this).data('color-name') == null then "-" else $(this).data('color-name')
    created_at = $(this).data('created-at')
    mfg_date = $(this).data('mfg-date')
    itemname = $(this).data('itemname')
    itemname = encodeURI(itemname)
    batch_no = $(this).data('batch-no')
    exp_date = $(this).data('exp-date')
    quantity = encodeURI($(this).data('quantity'))

    $("#print_count").val(parseInt(count))
    
    $('.bar-mrp').html "MRP : " + mrp
    $('.bar-title').html decodeURI(name)
    $('.bar-weight').html " G : " + wt
    $('.bar-making-cost').html "MC : " + mc + "&nbsp&nbsp&nbsp W : " + wst
    $('.bar-sku').html sku
    $('#radio_by_weight').html("<input class='type_radio' id='type_by_weight' name='type' value='by_weight' type='radio' data-f-l1="+site_name+" data-f-l2="+name+" data-f-l3="+sku+" data-b-l1='G : "+wt+"' data-count="+count+" data-b-l2='MC : "+mc+"      W : "+wst+"'><label for='type_by_weight'></label>")
    $('#radio_by_mrp').html("<input class='type_radio' id='type_by_mrp' name='type' value='by_mrp' type='radio' data-f-l1="+site_name+" data-f-l2='MRP : "+mrp+"' data-f-l3="+sku+" data-b-l1='MRP : "+mrp+"' data-b-l2='' data-count="+count+"><label for='type_by_mrp'></label>")
    $('#radio_by_catalog').html("<input class='type_radio' id='type_by_catalog' name='type' value='by_catalog' type='radio' data-f-l1="+site_name+" data-f-l2='"+mrp+"' data-f-l3="+sku+" data-b-l1='"+mrp+"' data-b-l2='' data-count="+count+" data-m-l1="+model_number+" data-s-l1="+size+" data-c-l1="+color_name+" data-created-at="+created_at+" data-mfg-date="+mfg_date+" data-itemname="+itemname+" data-batch-no="+batch_no+" data-exp-date="+exp_date+" data-quantity="+quantity+" checked='checked'><label for='type_by_catalog'></label>")
    $('#print_modal').modal("show")

  $(document).on "click", ".print-barcode",->
    if $('input:radio[name=type]:checked').length == 0
      Materialize.toast("Please select a pattarn first.", 5000)
    else
      f_l1 = $('input:radio[name=type]:checked').data('f-l1')
      f_l2 = $('input:radio[name=type]:checked').data('f-l2')
      f_l3 = $('input:radio[name=type]:checked').data('f-l3')
      f_l4 = $('input:radio[name=type]:checked').data('f-l4')
      b_l1 = $('input:radio[name=type]:checked').data('b-l1')
      b_l2 = $('input:radio[name=type]:checked').data('b-l2')
      # count = $('input:radio[name=type]:checked').data('count')
      count = $("#print_count").val()
      if count.length == 0
        count = 1
      m_l1 = $('input:radio[name=type]:checked').data('m-l1')
      s_l1 = decodeURI($('input:radio[name=type]:checked').data('s-l1'))
      c_l1 = $('input:radio[name=type]:checked').data('c-l1')
      d_l1 = $('input:radio[name=type]:checked').data('created-at')
      mfg_d1 = $('input:radio[name=type]:checked').data('mfg-date')
      itemname = decodeURI($('input:radio[name=type]:checked').data('itemname'))
      batch_no = $('input:radio[name=type]:checked').data('batch-no')
      exp_date = $('input:radio[name=type]:checked').data('exp-date')
      qty = decodeURI($('input:radio[name=type]:checked').data('quantity'))

      print_url = "http://localhost:3000/?f-l1=#{f_l1}&f-l2=#{f_l2}&f-l3=#{f_l3}&f-l4=#{f_l3}&b-l1=#{b_l1}&b-l2=#{b_l2}&b-l3=#{f_l3}&b-l4=#{f_l3}&m-l1=#{m_l1}&s-l1=#{s_l1}&c-l1=#{c_l1}&d-l1=#{d_l1}&mfg=#{mfg_d1}&production_itemname=#{itemname}&batchno=#{batch_no}&exp_date=#{exp_date}&quantity=#{qty}&count=#{Math.trunc(count)}"
      $.ajax
        type: 'GET'
        dataType: 'text'
        url: print_url
        success: (responseData, textStatus, jqXHR) ->
          alert responseData
          $('#print_modal').modal("hide")
        error: (responseData, textStatus, errorThrown) ->
          alert "Printer server is offline"
          console.log print_url
      return