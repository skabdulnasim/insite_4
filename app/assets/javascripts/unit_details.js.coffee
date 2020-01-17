# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
############################################ ajax loader image #################################################
  $(document).ajaxStart ->
    $("#background-blocker").css "display", "block"
    $(".maap").css "opacity", "0.7"
    return
  
  $(document).ajaxComplete ->
    $("#background-blocker").css "display", "none"
    $(".maap").css "opacity", "1.0"
    return

############################################ ajax save of "form of payments" #################################################
  $(".details_option_add").on "click", ->
    new_form_of_payment = $(".option_to_add").val()
    #alert new_form_of_payment
    request = undefined
    request = $.ajax(url: "/form_of_payments/save/?form_of_payment="+new_form_of_payment)
    request.done (data, textStatus, jqXHR) ->
      #console.log data
      gggg = "<div class='input-group'><input type='text' class='form-control' value= '"+new_form_of_payment+"'><span class='input-group-btn'><button class='btn btn-default' type='button'><i class='fa fa-trash-o'></i></button></span></div>"
      $("#dd").append(gggg)
      alert "You have successfully added an item"
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      #alert "AJAX Error:" + textStatus
      alert "There was a problem while adding the item"
      return 
    return

################################################################################################################################
############################################ ajax save of "atmospheres" #################################################
  $(".atmosphere").on "click", ->
    new_atmosphere = $(".atmosphere_to_add").val()
    #alert new_atmosphere
    request = undefined
    request = $.ajax(url: "/atmospheres/save/?form_of_payment="+new_atmosphere)
    request.done (data, textStatus, jqXHR) ->
      #console.log data
      gggg = "<div class='input-group'><input type='text' class='form-control' value= '"+new_atmosphere+"'><span class='input-group-btn'><button class='btn btn-default' type='button'><i class='fa fa-trash-o'></i></button></span></div>"
      $("#pp").append(gggg)
      alert "You have successfully added an item"
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      #alert "AJAX Error:" + textStatus
      alert "There was a problem while adding the item"
      return 
    return
################################################################################################################################
############################################ ajax save of "type_of_cuisines" #################################################
  $(".type_of_cuisines").on "click", ->
    new_type_of_cuisines = $(".type_of_cuisines_to_add").val()
    #alert new_atmosphere
    request = undefined
    request = $.ajax(url: "/type_of_cuisines/save/?form_of_payment="+new_type_of_cuisines)
    request.done (data, textStatus, jqXHR) ->
      #console.log data
      gggg = "<div class='input-group'><input type='text' class='form-control' value= '"+new_type_of_cuisines+"'><span class='input-group-btn'><button class='btn btn-default' type='button'><i class='fa fa-trash-o'></i></button></span></div>"
      $("#tt").append(gggg)
      alert "You have successfully added an item"
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      #alert "AJAX Error:" + textStatus
      alert "There was a problem while adding the item"
      return 
    return
################################################################################################################################
############################################ ajax save of "More info" #################################################
  $(".more_info").on "click", ->
    new_more_info = $(".more_info_to_add").val()
    #alert new_atmosphere
    request = undefined
    request = $.ajax(url: "/more_infos/save/?more_info="+new_more_info)
    request.done (data, textStatus, jqXHR) ->
      #console.log data
      gggg = "<div class='input-group'><input type='text' class='form-control' value= '"+new_more_info+"'><span class='input-group-btn'><button class='btn btn-default' type='button'><i class='fa fa-trash-o'></i></button></span></div>"
      $("#more_info").append(gggg)
      alert "You have successfully added an item"
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      #alert "AJAX Error:" + textStatus
      alert "There was a problem while adding the item"
      return 
    return 
################################################################################################################################
############################################ ajax save of "More info" #################################################
  $(".outlet_type").on "click", ->
    new_outlet_type = $(".outlet_type_to_add").val()
    #alert new_atmosphere
    request = undefined
    request = $.ajax(url: "/outlet_types/save/?outlet_type="+new_outlet_type)
    request.done (data, textStatus, jqXHR) ->
      #console.log data
      gggg = "<div class='input-group'><input type='text' class='form-control' value= '"+new_outlet_type+"'><span class='input-group-btn'><button class='btn btn-default' type='button'><i class='fa fa-trash-o'></i></button></span></div>"
      $("#outlet_type").append(gggg)
      alert "You have successfully added an item"
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      #alert "AJAX Error:" + textStatus
      alert "There was a problem while adding the item"
      return 
    return        
################################################################################################################################
############################################ ajax delete of "form of payments" #################################################
  $(".details_option_del").on "click", ->
    del_form_of_payment = $(this).attr("id")
    request_del = undefined
    request_del = $.ajax(url: "/form_of_payments/drop/?id="+del_form_of_payment)
    request_del.done (data, textStatus, jqXHR) ->
      #console.log data
      $("#del"+del_form_of_payment).remove() 
      alert "You have successfully deleted an item"     
      return
    request_del.error (jqXHR, textStatus, errorThrown) ->
      #alert "AJAX Error:" + textStatus
      alert "There was a problem while deleting the item"
      return 
    return

################################################################################################################################
############################################ ajax delete of "atmosphere" #################################################
  $(".details_atmos_del").on "click", ->
    del_atmos = $(this).attr("id")
    request_del = undefined
    request_del = $.ajax(url: "/atmospheres/drop/?id="+del_atmos)
    request_del.done (data, textStatus, jqXHR) ->
      #console.log data
      $("#delatm"+del_atmos).remove() 
      alert "You have successfully deleted an item"     
      return
    request_del.error (jqXHR, textStatus, errorThrown) ->
      #alert "AJAX Error:" + textStatus
      alert "There was a problem while deleting the item"
      return 
    return

################################################################################################################################
############################################ ajax delete of "atmosphere" #################################################
  $(".details_toc_del").on "click", ->
    del_toc = $(this).attr("id")
    request_del = undefined
    request_del = $.ajax(url: "/type_of_cuisines/drop/?id="+del_toc)
    request_del.done (data, textStatus, jqXHR) ->
      #console.log data
      $("#toc"+del_toc).remove() 
      alert "You have successfully deleted an item"     
      return
    request_del.error (jqXHR, textStatus, errorThrown) ->
      #alert "AJAX Error:" + textStatus
      alert "There was a problem while deleting the item"
      return 
    return

################################################################################################################################
  return
