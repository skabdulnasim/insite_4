# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->

############################################ AJAX THIRDPARTY TOGGLE #################################################
  $(".click_effect_to_add_toggle_unit_id").on "click", ->
    $("#_label_toggle_section").html ""
    $("#_select_toggle_section").html ""
    unitId = $(this).data("unit-id")
    $("#toggle_unit_id").val(unitId)
    request = $.ajax(url: "/units/fetch_sections/?unit_id="+unitId)
    request.done (data, textStatus, jqXHR) ->
      # alert JSON.stringify(data)
      console.log data
      data.sections = data
      result = undefined
      result = JST["templates/units/unit_toggle_sections_dropdown"](data)
      $("#_label_toggle_section").html "Section"
      $("#_select_toggle_section").html result
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      $("#_label_toggle_section").html ""
      $("#_select_toggle_section").html ""
      return 
    return

############################################ AJAX THIRDPARTY UPLOAD #################################################
  $("#_select_section").on "change", ->
    sectionId = $("#_select_section option:selected" ).val()
    $("#_label_thirdparty").html ""
    $("#_select_thirdparty").html ""
    request = $.ajax(url: "/units/fetch_thirdparties/?section_id="+sectionId)
    request.done (data, textStatus, jqXHR) ->
      # alert JSON.stringify(data)
      console.log data
      data.thirdparties = data
      result = undefined
      result = JST["templates/units/unit_thirdparties_dropdown"](data)
      $("#_label_thirdparty").html "Thirdparty"
      $("#_select_thirdparty").html result
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      $("#_label_thirdparty").html ""
      $("#_select_thirdparty").html ""
      return 
    return

  $(".click_effect_to_add_unit_id").on "click", ->
    $("#_label_section").html ""
    $("#_select_section").html ""
    unitId = $(this).data("unit-id")
    $("#thirdparty_upload_unit_id").val(unitId)
    request = $.ajax(url: "/units/fetch_sections/?unit_id="+unitId)
    request.done (data, textStatus, jqXHR) ->
      # alert JSON.stringify(data)
      console.log data
      data.sections = data
      result = undefined
      result = JST["templates/units/unit_sections_dropdown"](data)
      $("#_label_section").html "Section"
      $("#_select_section").html result
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      $("#_label_section").html ""
      $("#_select_section").html ""
      return 
    return

############################################ ajax loader image #################################################
  $(document).ajaxStart ->
    $("#background-blocker").css "display", "block"
    $(".maap").css "opacity", "0.7"
    return
  
  $(document).ajaxComplete ->
    $("#background-blocker").css "display", "none"
    $(".maap").css "opacity", "1.0"
    return

################################################################################################################
############################################ fetch units under a unit type and show in a dropdown########################################
  
  $(".dn").hide()
  $("#unit_unittype_id").on "change", ->
    currentSelection = undefined
    currentSelection = $(this).val()    
    request = undefined
    request = $.ajax(url: "/units/fetch_drop/?id="+currentSelection)
    #alert(d);
    request.done (data, textStatus, jqXHR) ->
      console.log data
      data.type_info = data
      result = undefined
      result = JST["templates/units/unit_parent"](data)
      $(".dn").show()
      $(".dn1").remove()
      $("#text-selector").html result
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      #alert "AJAX Error:" + textStatus
      $(".dn").hide()
      return 
    return
########################################################################################################################  
############################################ show units in google map #################################################
  # request1 = undefined
  # request1 = $.ajax(url: "/units/fetch_units.json")  
  # #alert request1
  # request1.done (data, textStatus, jqXHR) ->
  #   console.log data
  #   handler = Gmaps.build("Google")
  #   handler.buildMap
     
  #     # pass in other Google Maps API options here
  #     internal:
  #       id: "map"
  #   , ->
  #     markers = handler.addMarkers(data)
  #     handler.bounds.extendWith markers
  #     handler.fitMapToBounds()
  #     return

  #   return
  # request1.error (jqXHR, textStatus, errorThrown) ->
  #   #alert "AJAX Error:" + textStatus
  #   return 
  #alert json_array[0]
##########################################################################################################################  
  # $("#unit_address").geocomplete()
  $("#unit_address").on "keyup click", ->
    currentSelection = $(this).val()
    #alert currentSelection
    request_addrs = undefined
    request_addrs = $.ajax(url: "/units/fetch_unit_details?address="+currentSelection)  
    request_addrs.done (data, textStatus, jqXHR) ->
      console.log data
      sub_city = data.locality
      city = data.city
      state = data.state
      pincode = data.pincode
      country = data.country
      $("#unit_pincode").val(pincode)
      $("#unit_city").val(city)
      $("#unit_locality").val(sub_city)
      $("#unit_state").val(state)
      $("#unit_country").val(country)
      return
    request_addrs.error (jqXHR, textStatus, errorThrown) ->
      alert "AJAX Error:" + textStatus
      return 
    return

  $("#unit_unit_currency").on "keyup click change", ->
    value = $(this).val()
    if value.length == 0
      value = "N/A"
    $(".input-curency").html value
    return  

  $("#conversion-rate").on "keyup click change", ->
    value = $(this).val()
    $("#unit_conversion_rate").val(value)
    return  


  $(document).on 'click', 'form .remove_fields', (event)->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('.form-group').hide()
    event.preventDefault()

  $(document).on 'click', 'form .add_fields', (event)->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp,time))
    event.preventDefault()

  $(document).on 'click', '#is_account_creation', (event)->
    if this.checked
      $(this).val 'true'
    else
      $(this).val 'false'
    return

  return
      
