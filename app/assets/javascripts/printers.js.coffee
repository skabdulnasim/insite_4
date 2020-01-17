# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  
  $('#printer_assignable_type').change ->
    listen()
    return
  listen()  
  return

listen = ->
  model_name = $('#printer_assignable_type').val()
  if model_name
    printer_id = $('#printer_id').val()
    if printer_id == ""
      printer_id = "NULL"
    $.get '/printers/model_data_list/'+printer_id+'/' + model_name, (data) ->
      #$('#related_model_data').html data
      contentStr = ""
      for i in [0..(data.length-1)]
        contentStr += "<input type='checkbox' id='assign_#{data[i].id}' name='assignable_id[]' value='#{data[i].id}'>"
        contentStr += "<label for='assign_#{data[i].id}'>#{data[i].name}</label>"
      $('#related_model_data').html contentStr
      return
  else
    $('#related_model_data').empty
  return