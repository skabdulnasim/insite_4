# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
	$(".delivery_address").on "keyup click change", ->
    currentSelection = $(this).val()
    #alert currentSelection
    request_addrs = undefined
    request_addrs = $.ajax(url: "/delivery_addresses/fetch_address_details?address="+currentSelection)  
    request_addrs.done (data, textStatus, jqXHR) ->
      pincode = data.pincode
      $("#delivery_address_pincode").val(pincode)
      return
    request_addrs.error (jqXHR, textStatus, errorThrown) ->
      alert "AJAX Error:" + textStatus
      return 
    return
