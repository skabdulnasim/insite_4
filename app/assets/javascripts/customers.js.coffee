# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  $(".add_beneficiaries").hide()
  $(".add_csm").hide()
  $(document).on "click","input[name=beneficiary]",(event) ->
    if $(this).prop("checked")==true
      $(".add_beneficiaries").show()
      $(".add_beneficiaries").trigger("click")
    else
      $(".has_beneficiary").children(".card").remove()
      $(".add_beneficiaries").hide()
  $(document).on "click","input[name=csm]",(event) ->
    if($(this).prop("checked")==true)
      $(".add_csm").show()
      $(".add_csm").trigger("click")
    else
      $(".has_csm").children(".card").remove()
      $(".add_csm").hide()
  $(document).on "keyup click change",".delivery_address",(event)->
    currentSelection = $(this).val()
    #alert currentSelection
    request_addrs = undefined
    request_addrs = $.ajax(url: "/users/fetch_address_details?address="+currentSelection)  
    request_addrs.done (data, textStatus, jqXHR) ->
      console.log data
      locality = data.locality[0]
      city = data.city
      state = data.state
      pincode = data.pincode
      country = data.country
      $("#customer_addresses_attributes_0_pincode").val(pincode)
      $("#customer_addresses_attributes_0_city").val(city)
      $("#customer_addresses_attributes_0_locality").val(locality)
      $("#customer_addresses_attributes_0_state").val(state)
      return
    request_addrs.error (jqXHR, textStatus, errorThrown) ->
      alert "AJAX Error:" + textStatus
      return 
    return

  
  # Initializing the sale rule form wizard
  $('#wizard_vertical').steps
    headerTag: 'h3'
    bodyTag: 'section'
    transitionEffect: 'fade'
    stepsOrientation: 'horizontal'
    showFinishButtonAlways: true
    onStepChanging: (event, currentIndex, newIndex) ->
      true  
    onFinished: (event, currentIndex) ->
      form = $('.customer_form_wizard')
      form.submit()
      return  
  # For link_to_add_field remove
  $(document).on 'click', 'form .remove_cancelation_causes', (event)->
    cancelation_cause_id = $(this).data("cancelation-cause-id")
    remove_btn = $(this)
    $(this).closest('.form-group').remove()
    event.preventDefault()

  # For link_to_add_field 
  $(document).on 'click', 'form .add_fields', (event)->
    time = new Date().getTime()
    #alert $(this).data('type')
    #alert $("input[name=beneficiary_type]").val()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp,time))
    event.preventDefault()
