# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  ########################################  edit Product  #####################################################  
  $(".edit-product-unit").on "click", ->
      currentSelection = $(this).attr('id')
      #id_arr = currentSelection.split(',')
      request = undefined
      request = $.ajax(url: "/products/product_edit_unit/?id="+currentSelection) 
      request.done (data, textStatus, jqXHR) ->
        console.log data
        data.package_obj = data
  
        result = undefined
        result = JST["templates/products/edit_product_unit"](data)
        
        $("#reciveproductunitvalue").html result
        
        return
      request.error (jqXHR, textStatus, errorThrown) ->
        #alert "AJAX Error:" + textStatus
        return     
      return  
  ############################################################################################################  
  return
      