# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  ############### Callback function for shipment in Modal (Delivery VAN) ##################
  $(document).on "click", ".view-transfer-details",->
    transfer_id = $(this).attr('data-transfer-id')
    access_from = $(this).attr('data-access-from')
    primary_store_id = $(this).attr('data-primary-store')
    request = undefined
    request = $.ajax(url: "/stock_transfers/"+transfer_id+".json?store_id="+primary_store_id) 
    request.done (data, textStatus, jqXHR) ->
      data.package_obj = data
      data.access_from = access_from
      data.primary_store = primary_store_id
      result = undefined
      result = JST["templates/stores/transfer_details"](data)
      $("#showShipmentModalDetails").html result
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "AJAX Error:" + textStatus
      return 
    return
  return
