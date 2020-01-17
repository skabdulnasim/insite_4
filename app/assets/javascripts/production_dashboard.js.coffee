utc = (new Date).toJSON().slice(0, 10)
# End of use strict
$('document').ready ->
  $(document).ready ->
    request = $.ajax(
      type: 'GET'
      url: '/production_dashboard/get_production_date'
      dataType: "json"
    )
    request.done (data, textStatus, jqXHR) ->
      notStarted = 0
      started = 0
      halted = 0
      finished = 0
      i = 0
      today_production = data.all_data.today_production
      all_production = data.all_data.all_production
      console.log(all_production)
      #classifying different production state
      while i < today_production.length
        if today_production[i].status == '1'
          notStarted += 1
        else if today_production[i].status == '2'
          finished += 1
        else if today_production[i].status == '3'
          started += 1
        else
          halted += 1
        i++
      $("#new").html today_production.length
      $("#started").html started
      $("#halted").html halted
      $("#finished").html finished
      $('#calendar').fullCalendar
        header:
          left: 'prev,next today'
          center: 'title'
          right: 'month,agendaWeek,agendaDay'
        defaultDate: utc
        navLinks: true
        editable: false
        eventLimit: true
        events: get_event(all_production)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert 'Some error occured while requesting for data'
      return
    $(document).on "click", ".view_details", (event) ->
      status = $(this).data("id")
      request = $.ajax(
          type : "GET"
          url: "/production_dashboard/get_production_details_by_status"
          dataType: "json"
          data: 
            status: status
        )
      request.done (data, textStatus, jqXHR) ->
        console.log(data)
        data.response = data
        production_details = JST["templates/production_dashboard/production_dashboard"](data)
        $("#productionModalBody").html production_details
        return
      request.error (jqXHR, textStatus, errorThrown) ->
        alert 'Some error occured while requesting for data'
        return
      return  
    return
  return
  
get_event = (production) ->
      console.log(production)
      event_arr = []
      i = 0
      while i < production.length
        event = {}
        event.title =  "#"+production[i].id+" "+(production[i].name)
        event.start = production[i].start_date.slice(0,10)
        if production[i].status == "1"
          event.color = "#39A4D9"
        else if production[i].status == "2"
          event.color = "#60BF67"
        else if production[i].status == "3"
          event.color = "#F3A421"
        else
          event.color = "#DC6146"
        event.url= "/stores/"+production[i].unit_id+"/stock_productions/"+production[i].id
        event_arr.push event
        i++
      event_arr
