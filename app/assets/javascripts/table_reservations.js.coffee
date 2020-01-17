
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->

  details_error_html = """
                        <div class=\'alert alert-danger alert-dismissable\'><button type=\'button\' class=\'close\' data-dismiss=\'alert\' aria-hidden=\'true\'>&times;</button>Please Enter Customer Details and Select Section</div>
                       """  

  time_error_html    = """
                        <div class=\'alert alert-danger alert-dismissable\'><button type=\'button\' class=\'close\' data-dismiss=\'alert\' aria-hidden=\'true\'>&times;</button>Please Choose Time</div>
                       """   

  pax_error_html     = """
                        <div class=\'alert alert-danger alert-dismissable\'><button type=\'button\' class=\'close\' data-dismiss=\'alert\' aria-hidden=\'true\'>&times;</button>Please Enter PAX</div>
                       """   

  pax_exceds_html    = """
                        <div class=\'alert alert-danger alert-dismissable\'><button type=\'button\' class=\'close\' data-dismiss=\'alert\' aria-hidden=\'true\'>&times;</button>Need to Drop another Table</div>
                       """

  tablearray = []


  this.update_reservation = update_reservation = (element,reservation_id) ->
    url           = window.location.href
    request       = undefined
    request       = $.ajax(url: "/table_reservations/#{reservation_id}", 
    dataType:"json",
    data: {table_reservation: {status:"3"}},
    type: "PUT" )
    request.done (data, textStatus, jqXHR) ->
      window.location.replace url
      return

  $('.drop_zone').on "click",->
    in_time           = $(this).attr 'data-time-min'
    $(this).toggleClass 'selected' 
    timearray         = []
    $('.selected').each ->
      current_element = undefined
      current_element = $(this).attr 'data-time-min'
      timearray.push current_element
      $(this).attr 'time-span', timearray
      return
    return

  $('#save').on "click",->
    url               = window.location.href
    #alert $('#status').val()
    if $('#timeslot').attr 'tables-id' 
      if $('#customer_name').val() and $('#customer_mobile').val() and $('.selected').attr('time-span') and $('li#sections.active a').attr('id')
        time_array    = $('.selected:last').attr('time-span').split ','
        tables_array  = $('#timeslot').attr('tables-id').split ','
        request       = undefined
        request       = $.ajax(url: "/table_reservations/", 
        dataType:"json",
        data: {table_reservation: {from_time:"#{time_array[0]}",to_time:"#{time_array[time_array.length-1]}",customer_name:"#{$('#customer_name').val()}",head_count:"#{$('#pax').val()}",reservation_date:"#{$('#date').val()}",unit_id:"#{$('#unit_name').val()}",section_id:"#{$('li#sections.active a').attr('id')}",contact_no:"#{$('#customer_mobile').val()}"},status:"#{$('#status').val()}",table_id : JSON.stringify(tables_array)},
        type: "POST",
        )
        request.done (data, textStatus, jqXHR) ->
          
          window.location.replace url
          return
      else
        $('#message').html details_error_html
    else
      if $('#customer_name').val() and $('#customer_mobile').val() and $('.selected').attr('time-span') and $('li#sections.active a').attr('id')
        time_array    = $('.selected:last').attr('time-span').split ','
        request       = undefined
        request       = $.ajax(url: "/table_reservations/",  
        dataType:"json",
        type: "POST",
        data: {table_reservation: {from_time:"#{time_array[0]}",to_time:"#{time_array[time_array.length-1]}",customer_name:"#{$('#customer_name').val()}",head_count:"#{$('#pax').val()}",reservation_date:"#{$('#date').val()}",unit_id:"#{$('#unit_name').val()}",section_id:"#{$('li#sections.active a').attr('id')}",status:"#{$('#status').val()}",contact_no:"#{$('#customer_mobile').val()}"}}
        )
        request.done (data, textStatus, jqXHR) ->
          data.package_obj  = data
          result            = undefined
          result            = JST["templates/table_reservations/customer_details"](data)
          return
        window.location.replace url
      else
        $('#message').html details_error_html
    return
  

  $("#save_on_table").on "click",->
    url               = window.location.href
    #if ($('#customer_name_t').val() && $('#customer_mobile_t').val() && $('.selected').attr('time-span') && $('li#sections.active a').attr('id'))
    time_array        = $('.selected:last').attr('time-span').split ','
    request           = undefined
    request           = $.ajax(url: "/table_reservations/", 
    dataType:"json",
    type: "POST",
    data: {table_reservation: {from_time:"#{time_array[0]}",status:"#{$('#status').val()}",to_time:"#{time_array[time_array.length-1]}",customer_name:"#{$('#customer_name_t').val()}",head_count:"#{$('#pax_t').val()}",reservation_date:"#{$('#date').val()}",unit_id:"#{$('#unit_name').val()}",section_id:"#{$('li#sections.active a').attr('id')}",contact_no:"#{$('#customer_mobile_t').val()}"}}
    )
    request.done (data, textStatus, jqXHR) ->
      window.location.replace url
      return      
    return

  ############################## for tables on section wise ####################################

  $(".tab_section").on "click",->
    #get_customer_tables_list
    request           = undefined
    request           = $.ajax(url: "/table_reservations/get_tables_list/#{$(this).attr('id')}", 
    dataType:"json",
    type: "GET"
    )
    request.done (data, textStatus, jqXHR) ->
      console.log data
      data.package_obj = data
      result           = undefined
      result           = JST["templates/table_reservations/get_tables"](data)
      $("#tab-content").html result
      return
    return

  
  $('#tab-content,#table_view_id').on "click",->
    $('.draggable').draggable
      appendTo: 'body'
      helper: 'clone'
    $('.drop_zone').droppable drop: (event, ui) ->
      if($('#pax').val())
        if ($('.selected').attr 'time-span')
          tablearray.push(ui.draggable.attr 'table-id')
          $('#timeslot').attr 'tables-id', tablearray
          pax = ui.draggable.attr 'pax'
          table_name    = ui.draggable.attr 'table-name'
          $('.selected').append '<span class=\'label label-success allot_tables\' id=\'#{ui.draggable.attr(\'table-id\')}\'>' + table_name + ' | <b>' + pax + '</b></span><br>'
        else
          $('#message').html time_error_html
      else
        $('#message').html '<div class=\'alert alert-danger alert-dismissable\'><button type=\'button\' class=\'close\' data-dismiss=\'alert\' aria-hidden=\'true\'>&times;</button>Please Enter PAX</div>'
      return
    $('.drop_zone_on_update').droppable drop: (event, ui) ->
      tablearray.push(ui.draggable.attr 'table-id')
      reservation_id    = $(this).attr 'reservation_id'
      $('#update_button' + reservation_id).html("<button type='button' class='btn btn-success btn-xs update_button_save' id='update_button_save' reservation_id='#{$(this).attr('reservation_id')}'  style='width:100%'>Update</button>");
      $('#timeslot').attr 'tables-id', tablearray
      pax               = ui.draggable.attr 'pax' 
      table_name        = ui.draggable.attr 'table-name'
      $('#drop_zone_on_update' + reservation_id).append '<span class=\'label label-success allot_tables\' id=\'#{ui.draggable.attr(\'table-id\')}\'>' + table_name + ' | <b>' + pax + '</b></span><br>'
      return
    return

  $('#timeslot_table').on "click",->
    $('.drop_on_update').droppable drop: (event, ui) ->
      table_id          = $(this).attr 'table_id'
      capacity          = $(this).attr 'table_capacity'
      customer_id       = ui.draggable.attr 'customer-id'
      pax               = ui.draggable.attr 'head-count'
      to_time           = $(this).attr 'data-time-min'
      time_diff         = ui.draggable.attr('to-time') - ui.draggable.attr('from-time')
      from_time         = parseInt(to_time)+parseInt(time_diff)
      $('#timeslot_table').attr 'data-to-time', to_time
      $('#timeslot_table').attr 'data-from-time', from_time
      if pax > capacity
        pax = pax - capacity
        $('#message_table').html pax_exceds_html 
        $("#customer#{ui.draggable.attr 'customer-id'}").attr 'head-count',pax
        tablearray.push($(this).attr 'table_id')
        $('#timeslot_table').attr 'tables-id', tablearray
        for i in [(to_time)..(from_time)]
          $("#booked#{i}#{$(this).attr('table_id')}").addClass('booked_time_table')
          $("#booked#{i}#{$(this).attr('table_id')}").append("<span class='label label-success allot_tables'>#{ui.draggable.attr('customer-id')}</span>")
        #$("#on_update#{$(this).attr('table_id')}").html("<button type='button' class='btn btn-success btn-xs update_button_save' id='update_button_save_on_table' reservation_id=#{ui.draggable.attr('customer-id')} table_id=#{$(this).attr('table_id')} >Update</button>")
      else  
        tablearray.push($(this).attr 'table_id')
        $('#timeslot_table').attr 'tables-id', tablearray
        for i in [(to_time)..(from_time)]
          $("#booked#{i}#{$(this).attr('table_id')}").addClass('booked_time_table')
          $("#booked#{i}#{$(this).attr('table_id')}").append("<span class='label label-success allot_tables'>#{ui.draggable.attr('customer-id')}</span>")
        #$("#customer#{ui.draggable.attr 'customer-id'}").remove()
        $("#on_update#{ui.draggable.attr 'customer-id'}").html("<button type='button' class='btn btn-success btn-xs update_button_save' id='update_button_save_on_table' reservation_id=#{ui.draggable.attr('customer-id')}>Update</button>")
      return

  $('.update_button').on "click",->
    $('#update_button_save').on "click",->
      url               = window.location.href
      tables_array      = $('#timeslot').attr('tables-id').split ','
      request           = undefined
      request           = $.ajax(url: "/table_reservations/meta_data_cust/#{$(this).attr('reservation_id')}", 
      dataType:"json",
      data: {table_id : JSON.stringify(tables_array)},
      type: "POST",
      )
      request.done (data, textStatus, jqXHR) ->
        window.location.replace url
        return
        
      return
    return

  $('.on_update').on "click",->
    $('#update_button_save_on_table').on "click",->
      url               = window.location.href
      tables_array      = $('#timeslot_table').attr('tables-id').split ','
      to_time           = $('#timeslot_table').attr('data-to-time')
      from_time         = $('#timeslot_table').attr('data-from-time')
      request           = undefined
      request           = $.ajax(url: "/table_reservations/meta_data_table/",dataType:"json", data: {table_reservation_id : "#{$(this).attr('reservation_id')}",to_time:"#{$('#timeslot_table').attr('data-to-time')}",from_time:"#{$('#timeslot_table').attr('data-from-time')}",table_id : JSON.stringify(tables_array)},
      type: "POST"
      )
      request.done (data, textStatus, jqXHR) ->
        window.location.replace url
        return
      return



  return