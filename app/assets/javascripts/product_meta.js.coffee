# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  atLeastOneIsChecked = $('input[name="checked_raw[]"]:checked').length
  #$(".ll").hide()
  #$(".InputAmount").attr("readonly", "readonly")
  $('input[name="checked_raw[]"]:checked').each ->
    id1 = $(this).attr('id')
    #alert id1
    #$(".ll"+id1).show()
    $("#InputAmount_quantity"+id1).prop('readonly',false)
    $("#InputAmount_quantity"+id1).prop('required', true)
    
  $('.check').on "click", ->
    id = $(this).attr('id')
    if (this.checked)
      #$(".ll"+id).show()
      $("#InputAmount_quantity"+id).prop('readonly',false)
      #$('#quantity'+id).prop('required', true)
      $("#InputAmount_quantity"+id).prop('required', true)
    else
      #$(".ll"+id).hide()
      $("#InputAmount_quantity"+id).prop('readonly',true)
      #$('#quantity'+id).prop('required', false)
      $("#InputAmount_quantity"+id).prop('required', false)
    return
    
############################# This is for product info #################################

  $(".add_info").on "click", ->    
    result = undefined
    result = JST["templates/product_meta/add_info"]
    $(".add_more_info").append result
    $(".rm_info").bind "click", ->
      close_info_box(this)
      return
    return

  $(".remove_info").on "click", ->
    close_info_box(this)
    return

########################################################################################  

  close_info_box = (dd) ->
    $(dd).closest(".info_box").remove()
    
  return
