# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  $('.check').on "click", ->
    id = $(this).attr('id')
    if (this.checked)
      $("#action_"+id).prop('disabled', false)
      $("#action_"+id).prop('required', true)     
    else
      $("#action_"+id).prop('required', false)
      $("#action_"+id).prop('disabled', true)
    return

  $('.check-action-parent').on "click", ->
    id = $(this).attr('data-controller')
    if (this.checked)
      $(".check-action-child-"+id).prop('checked', true)     
    else
      $(".check-action-child-"+id).prop('checked', false)
    return

return
