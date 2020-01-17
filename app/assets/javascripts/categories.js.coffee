# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#---------------------------------------------------- For tooltip ---------------------------------------------------

  
  
$(document).ready ->
  
  $(".plus").on "click", ->
    #parent_id =  this.id
    name_id = this.id
    name_id_arr = name_id.split('~');
    #alert name_id_arr
    parent_id = name_id_arr[0]
    parent_name = name_id_arr[1]
    $(".parent_val").val(parent_id)
    $(".parent_name").val(parent_name)
    return 
    
################################ action Box in category list page ###########################################
  $(".categories_action_box").hide()
  $(".categories_action_list").on "mouseover", ->
    id = $(this).attr('id')
    $("#categories_action_box"+id).show()
    #alert id
    return 
  $(".categories_action_list").on "mouseout", ->
    $(".categories_action_box").hide()
    return 
####################################################################################################
  return
