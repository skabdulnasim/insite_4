# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

refetch_events_and_close_dialog = ->
  $('#calendar').fullCalendar 'refetchEvents'
  $('.dialog:visible').dialog 'destroy'
  return

showPeriodAndFrequency = (value) ->
  switch value
    when 'Daily'
      $('#period').html 'day'
      $('#frequency').show()
    when 'Weekly'
      $('#period').html 'week'
      $('#frequency').show()
    when 'Monthly'
      $('#period').html 'month'
      $('#frequency').show()
    when 'Yearly'
      $('#period').html 'year'
      $('#frequency').show()
    else
      $('#frequency').hide()
  return

$(document).ready ->
  future_orders = $("#future_orders").val()
  alert future_orders
  $('#calendar').fullCalendar
    editable: true
    header:
      left: 'prev,next today',
      center: 'title',
      right: 'month'
    defaultView: 'month'
    height: 500
    slotMinutes: 15
    loading: (bool) ->
      if bool
        $('#loading').show()
      else
        $('#loading').hide()
      return
    events: "/api/restapi/get_orders.json?order_ids[]="+future_orders
    timeFormat: 'h:mm tt{ - h:mm tt} '
    dragOpacity: '0.5'
    # eventRender: function(event, element) {
    #   element.element.qtip({
    #     content: event.description
    #   })
    # }
    eventDrop: (event, dayDelta, minuteDelta, allDay, revertFunc) ->
      return
    eventResize: (event, dayDelta, minuteDelta, revertFunc) ->
      return
    eventClick: (event, jsEvent, view) ->
      console.log event
      return