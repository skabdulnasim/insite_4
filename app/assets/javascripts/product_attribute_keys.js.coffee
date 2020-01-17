# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  
  # Add options for attribute
  $(document).on "click", ".add_fields", (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()

  # Define active attribute fields based on input type
  setAttributeFields = ->
    inputVal = $("#product_attribute_key_input_type").val()
    if inputVal is "select"
      $(".product_attribute_key_is_for_variable_product_row").show()
      $(".product_attribute_key_options_row").show()
      $(".product_attribute_key_default_value_row").hide()
    else if inputVal is "file_field"
      $(".product_attribute_key_default_value_row").hide()
      $(".product_attribute_key_options_row").hide()
      $(".product_attribute_key_is_for_variable_product_row").hide()
    else
      $(".product_attribute_key_default_value_row").show()
      $(".product_attribute_key_options_row").hide()
      $(".product_attribute_key_is_for_variable_product_row").hide()
    return

  # Set attribute fields based on input type
  setAttributeFields()

  $(document).on "change", "#product_attribute_key_input_type",->
    setAttributeFields()
    return
  return
