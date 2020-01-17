# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  $('.input_type_option').hide()

	# Initializing the sale rule form wizard
  $('#wizard').steps
    headerTag: 'h3'
    bodyTag: 'section'
    transitionEffect: 'fade'
    stepsOrientation: 'horizontal'
    showFinishButtonAlways: true
    enableAllSteps: true
    onStepChanging: (event, currentIndex, newIndex) ->
      true  
    onFinished: (event, currentIndex) ->
      selected = []
      $('.unit_checkbox:checkbox:checked').map ->
        selected.push $(this).attr('name')
      if selected.length == 0
        Materialize.toast("Question must be allocated to one Outlet.", 3000, 'rounded red') 
        return false    
      form = $('.question_option_form')
      form.submit()
      return

  $(document).on "change", "#question_option_type", (event) ->
    if $("#question_option_type option:selected").val() == 'Input'
      $(document).find("textarea[id*=question_options_attributes_]").prop("disabled", "disabled")
      $(document).find("input[id*=question_options_attributes_]").prop("disabled", "disabled")
      $(".add_options").hide()
      $('.input_type_option').show()
    else
      
      $(document).find("textarea[id*=question_options_attributes_]").removeAttr("disabled")
      $(document).find("input[id*=question_options_attributes_]").removeAttr("disabled")
      $(".add_options").show()
      $('.input_type_option').hide()

  $(document).on "click", ".add_fields", (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()

  ########################## update question status ##########################
  $('.update_question_status').click ->
    question_id = $(this).data('question-id')
    active = $(this).attr('data-value-active')
    inactive = $(this).attr('data-value-inactive')
    question_status_value = if @checked then active else inactive
    request = $.ajax(
      type: 'POST'
      url: '/questions/update_status'
      data:
        question_id: question_id
        question_status: question_status_value
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Question status updated to: #{question_status_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "Error"
      return
    return