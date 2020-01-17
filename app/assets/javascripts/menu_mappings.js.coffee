# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->

	# Initializing the menu mappings form wizard
  $('#wizard_vertical').steps
    headerTag: 'h3'
    bodyTag: 'section'
    transitionEffect: 'fade'
    stepsOrientation: 'horizontal'
    showFinishButtonAlways: true
    onStepChanging: (event, currentIndex, newIndex) ->
      true  
    onFinished: (event, currentIndex) ->
      form = $('.menu_mapping_form_wizard')
      form.submit()
      return

  $(document).on "change", ".menu_mapping_status_update",->
    menu_mapping_id = $(this).attr('data-menu-mapping-id')
    url = "/menu_mappings/#{menu_mapping_id}/update_status"
    request = $.ajax(
      type: 'POST'
      url: url
      data:
        menu_mapping_id: menu_mapping_id
    )
    request.done (data, textStatus, jqXHR) ->
      if data.status=="inactive"
        Materialize.toast('Menu mapping has been disabled',4000)
      else if data.status=="active"
        Materialize.toast('Menu mapping has been enabled',4000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("AJAX Error",4000)
      return
    
    return

  return
