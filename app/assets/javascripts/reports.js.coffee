# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  $('input[type=\'radio\']').click (event) ->
    # If the button is selected.
    if $(this).hasClass('checked')
      # Remove the placeholder.
      $(this).removeClass 'checked'
      # And remove the selection.
      $(this).removeAttr 'checked'
      # If the button is not selected.
    else
      # Remove the placeholder from the other buttons.
      $('input[type=\'radio\']').each ->
        $(this).removeClass 'checked'
        return
      # And add the placeholder to the button.
      $(this).addClass 'checked'
    return

  $('form#check_box_validate').submit ->
    if $(this).find('input[type=\'checkbox\']:checked').length == 0
      alert 'You must select at least one option.'
      return false
    return
    
  #$('form#check_box_validate').submit ->
    #if $(this).find('input:checked').length == 0
    #No checkbox checked
      #alert('You must select at least one option.')
      #return false
    #return
  return
