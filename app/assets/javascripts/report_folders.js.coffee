# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


$(document).ready ->
  $("input:radio[name='report_folder[master_model]']").change ->
    master_model = $(this).val()
    console.log master_model
    if master_model
      $.get "/report_folders/select_relation/"+ master_model, (data) ->
        $("#relation_model").html data
        footerDiv = $('.col-sm-2').first()
        scrollPos = footerDiv.offset().top
        $(window).scrollTop scrollPos
        return
    else
      $("#relation_model").empty
    return
  return