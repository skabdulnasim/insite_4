# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready -> 
################################ action Box in menu category list page ###########################################
  $(".menu_categories_action_box").hide()
  $(".menu_categories_action_list").on "mouseover", ->
    id = $(this).attr('id')
    $("#menu_categories_action_box"+id).show()
    #alert id
    return 
  $(".menu_categories_action_list").on "mouseout", ->
    $(".menu_categories_action_box").hide()
    return 
####################################################################################################
  return