# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->  
  $("#customer-container").hide()
  $(".mobile-search").on "click", ->
    mobile_no = $("#contact-number").val()
    request = $.ajax(
      type: 'POST'
      url: "/api/v2/customers/find_by_login.json"
      dataType: "json"
      data:
        login: mobile_no
    )
    request.done (data, textStatus, jqXHR) ->
      $("#customer-container").show()
      Materialize.toast("#{data.messages.simple_message}", 5000)
      if data.status is "ok"
        $("#customer_first_name").val(data.data.firstname)
        $("#customer_last_name").val(data.data.lastname)
        $("#loyalty_card_name_on_card").val("#{data.data.firstname} #{data.data.lastname}")
        $("#loyalty_card_customer_id").val(data.data.id)
        $(".register-customer").hide()
      else
        $("#customer_first_name").val("")
        $("#customer_last_name").val("")
        $("#loyalty_card_name_on_card").val("")
        $("#loyalty_card_customer_id").val("")
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      $("#customer-container").show()
      $("#customer-ddressModalBody").html(errorThrown)
      return       
    return 
  $(".register-customer").on "click", ->
    mobile_no = $("#contact-number").val()
    firstname = $("#customer_first_name").val()
    lastname = $("#customer_last_name").val()
    $(".register-customer").show()
    Materialize.toast("Please provide customer first name", 5000) if firstname is ""
    Materialize.toast("Please provide customer last name", 5000) if lastname is ""
    Materialize.toast("Please provide customer mobile number", 5000) if mobile_no is ""

    request = $.ajax(
      type: 'POST'
      url: "/api/v2/customers.json"
      dataType: "json"
      data:
        contact_no:       mobile_no
        firstname:        firstname
        lastname:         lastname
    )
    request.done (data, textStatus, jqXHR) ->
      Materialize.toast("#{data.messages.simple_message}", 5000)
      if data.status is "ok"
        $("#customer_first_name").val(data.data.firstname)
        $("#customer_last_name").val(data.data.lastname)
        $("#loyalty_card_name_on_card").val("#{data.data.firstname} #{data.data.lastname}")
        $("#loyalty_card_customer_id").val(data.data.id)
        $(".register-customer").hide()
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      $("#customer-container").show()
      $("#customer-ddressModalBody").html(errorThrown)
      return       
    return
  return