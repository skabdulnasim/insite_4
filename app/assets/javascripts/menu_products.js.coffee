# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

######################################### Activate / deactivate menu items ############################################
$(document).ready ->   
  $(".icon_show").on "click", ->
    #alert "hi"
    product_id = $(this).attr("id")
    #alert menu_id
    request = undefined
    request = $.ajax(url: "/menu_products/mode_toggle/?id="+product_id) 
    request.done (data, textStatus, jqXHR) ->
      console.log data
      alert "You have successfully activated this menu-item."
      location.reload(true)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "AJAX Error:" + textStatus
      return 
    return
  $(".icon_hide").on "click", ->
    #alert "hi"
    product_id = $(this).attr("id")
    #alert menu_id
    request = undefined
    request = $.ajax(url: "/menu_products/mode_toggle/?id="+product_id) 
    request.done (data, textStatus, jqXHR) ->
      console.log data
      alert "You have successfully de-activated this menu-item."
      location.reload(true)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "AJAX Error:" + textStatus
      return 
    return
####################################################################################################################################
  ########################## Group Box in Product list page #############################
    
  # $(".menu_icon_grouped").on "click", ->
  #   currentSelection = this.id
  #   request = undefined
  #   request = $.ajax(url: "/menu_products/find_sub_menu_products/?id="+currentSelection)   
  #   request.done (data, textStatus, jqXHR) ->
  #     console.log data
  #     data.sub_products = data
  #     result = undefined
  #     result = JST["templates/menu_products/group_box"](data)
  #     $("#"+currentSelection).append result
  #     $(".cross").bind "click", ->
  #       close_box()
  #       return
  #     $("body").bind "click", ->
  #       close_box()
  #       return
  #     return
  #   request.error (jqXHR, textStatus, errorThrown) ->
  #     alert "AJAX Error:" + textStatus
  #     return 
  #   return
  # close_box = () ->
  #   $("i").closest("#box").fadeOut("slow")
  #   return
  
####################################################################################################################################
################################ action Box in menu category list page ###########################################
  $(".menu_products_action_box").hide()
  $(".menu_products_action_list").on "mouseover", ->
    id = $(this).attr('id')
    #alert id
    $("#menu_products_action_box"+id).show()
    
    return 
  $(".menu_products_action_list").on "mouseout", ->
    $(".menu_products_action_box").hide()
    return 
####################################################################################################
################## tax group dropdown when create menu product ###################
  $("#mp_unit").on "change", ->
    select = $(this).val()
    request = undefined
    request = $.ajax(url: "/units/get_tax_group/?id="+select)
    request.done (data, textStatus, jqXHR) ->
      console.log data
      data.tax_group_details = data
      result = undefined
      result = JST["templates/menu_products/tax_group"](data)
      $("#tax-selector").html result
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      #alert "AJAX Error:" + textStatus
      $(".dn").hide()
      return
    return

##############################################################################################
################## tax calculate when create menu product ###################
  $("#menu_product_tax_group_id").on "change", ->
    $("#menu_product_sell_price_without_tax").val("")
    $("#menu_product_sell_price").val("")
    return

  $(".set_tax").on "click", ->
    tax = $("#menu_product_tax_group_id").find(':selected').attr('data-tax')
    #alert tax
    $("#menu_product_sell_price_without_tax").val("")
    $("#menu_product_sell_price").val("")
    $("#simple_tax_amnt_field").val(tax)
    $("#cess_tax_amnt_field").val(0)
    return

  return