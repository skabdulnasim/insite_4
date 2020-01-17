# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
# $(document).ready ->
#   hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
#   for(i = 0; i < hashes.length; i++) ->
#     hash = hashes[i].split('=')
#     vars.push(hash[0])
#     vars[hash[0]] = hash[1]
#     return
#   # alert vars
#   $("select.category-list select").val()
#   return
$(document).ready ->
  if $("#unit_menu_card").val() == null
    $("#nc-category-submit-button").attr("disabled", true)
  return  
$(document).on "change", ".category-list", ->
  # alert "Ok"
  category_id = $(this).val()
  current_url = window.location.href
  new_url = current_url+"&category_id="+category_id
  location.href = new_url
  return

$(document).on "change", ".category-units", ->
  unit_id = $(this).val()
  request = $.ajax
              url: "/nc_report/?unit_id="+unit_id
              method: 'GET'
              dataType: "json"
  request.done (data, textStatus, jqXHR) ->
    console.log data
    data.menu_card = data
    result = JST["templates/reports/menu_card"](data)
    $("#unit_menu_card").empty()
    $(".unit-menu-card").show()
    $("#unit_menu_card").append result
    if $("#unit_menu_card").val() != ''
      $("#nc-category-submit-button").attr("disabled", false)
    else
      $("#nc-category-submit-button").attr("disabled", true) 
    return
  request.error (jqXHR, textStatus, errorThrown) ->
    alert "AJAX Error:" + textStatus
    return    