# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  if $("#unit_menu_card").val() == null
    $("#category-submit-button").attr("disabled", true)
  if $("#menu_card_unit").val() == null
    $("#interval-submit-button").attr("disabled", true)
  $(document).on "keyup change", ".sales-by-date-input",->
    from_date = $(".stock-from-date").val()
    store_id = $(".export-stock-report").attr("date-store-id")
    href = "/sale_reports/by_date.csv?&from_date=#{from_date}"
    $(".export-by-date-sales-report").prop('href', href);
    return

$(document).on "change", "#discountmode",->
    from_date = $(this).data('from-date')
    to_date = $(this).data('to-date')
    deliverable_type = $("#deliverable_type").val()
    unit_id = $(this).data("unit-id")
    section_id = $("#section_id").val()
    if $(this).prop("checked") == true
      href = "/sale_reports/by_date.csv?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&deliverable_type=#{deliverable_type}&discountmode=1"
      href_pdf = "/sale_reports/by_date.pdf?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&deliverable_type=#{deliverable_type}&discountmode=#{discountmode}&discountmode=1"
    else
      href = "/sale_reports/by_date.csv?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&deliverable_type=#{deliverable_type}"
      href_pdf = "/sale_reports/by_date.pdf?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&deliverable_type=#{deliverable_type}&discountmode=#{discountmode}"
    # href = "/sale_reports/by_date.csv?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&deliverable_type=#{deliverable_type}&discountmode=#{discountmode}"
    # $(".export-by-date-sales-report").prop('href', href+"&section_id=#{section_id}");
    # href_pdf = "/sale_reports/by_date.pdf?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&deliverable_type=#{deliverable_type}&discountmode=#{discountmode}"    
    # $(".export-by-date-sales-report_pdf").prop('href',href_pdf+"&section_id=#{section_id}");
    if $("#deliverable_type").val()=="Section"
      $(".export-by-date-sales-report").prop('href', href+"&section_id=#{section_id}");
      $(".export-by-date-sales-report_pdf").prop('href',href_pdf+"&section_id=#{section_id}");
    return  

$(document).on "change", "#deliverable_type",->
    deliverable_type = $(this).val()
    from_date = $(this).data('from-date')
    to_date = $(this).data('to-date')
    unit_id = $(this).data("unit-id")
    section_id = $("#section_id").val()
    href = "/sale_reports/by_date.csv?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&deliverable_type=#{deliverable_type}"
    if $(this).val()=="Section"
      $(".export-by-date-sales-report").prop('href', href+"&section_id=#{section_id}");
      $(".export-by-date-sales-report_pdf").prop('href',href_pdf+"&section_id=#{section_id}");
    href_pdf = "/sale_reports/by_date.pdf?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&deliverable_type=#{deliverable_type}"     
    return

$(document).on "change", "#report_type",->
    report_type = $(this).val()
    from_date = $('#from_date').val()
    to_date = $('#to_date').val()
    unit_id = $("#unit_id").val()
    href = "/sale_reports/by_date_boh.csv?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&report_type=#{report_type}"
    $(".export-by-date-sales-report").prop('href', href);
    return

$(document).on "change", "#report_type_cod",->
    report_type_cod = $(this).val()
    from_date = $('#from_date').val()
    to_date = $('#to_date').val()
    unit_id = $("#unit_id").val()
    href = "/sale_reports/by_date_cod.csv?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&report_type_cod=#{report_type_cod}"
    $(".export-by-date-sales-report").prop('href', href);
    return

$(document).on "change", "#section_id",->
  section_id = $(this).val()
  from_date = $(this).data('from-date')
  to_date = $(this).data('to-date')
  unit_id = $(this).data("unit-id")
  href = "/sale_reports/by_date.csv?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&section_id=#{section_id}"
  deliverable_type = "Section"
  $(".export-by-date-sales-report").prop('href', href+"&deliverable_type=#{deliverable_type}");
  href_pdf = "/sale_reports/by_date.pdf?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&section_id=#{section_id}"    
  $(".export-by-date-sales-report_pdf").prop('href',href_pdf+"&deliverable_type=#{deliverable_type}");
  return

$(document).on "change", "#section",->
  section_id = $(this).val()
  from_date = $('#from_date').val()
  to_date = $('#to_date').val()
  unit_id = $("#unit_id").val()
  href = "/sale_reports/adons_sales_reports.csv?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&section=#{section_id}"
  alert href
  $(".export-by-addonn-sales-report").prop('href', href);
  return  

$(document).on "change", "input[type=\'checkbox\']", ->
  if $('input:checkbox:checked').length > 0
    $("#summary-submit-button").attr("disabled", false)
  else
    $("#summary-submit-button").attr("disabled", true)
  return

$(document).on "change", ".category-list", ->
  # alert "Ok"
  category_id = $(this).val()
  current_url = window.location.href
  new_url = current_url+"&category_id="+category_id
  location.href = new_url
  return

$(document).on "change", ".user_list", ->
  #alert "Ok"
  $( "#user_sales" ).submit()
  return

$(document).on "change", ".category-units", ->
  unit_id = $(this).val()
  request = $.ajax
              url: "/sale_reports/?unit_id="+unit_id
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
      $("#category-submit-button").attr("disabled", false)
    else
      $("#category-submit-button").attr("disabled", true)
    return
  request.error (jqXHR, textStatus, errorThrown) ->
    alert "AJAX Error:" + textStatus
    return

$(document).on "change", ".units_cat", ->
  unit_id = $(this).val()
  request = $.ajax
              url: "/sale_reports/?unit_id="+unit_id
              method: 'GET'
              dataType: "json"
  request.done (data, textStatus, jqXHR) ->
    console.log data
    data.menu_card = data
    result = JST["templates/reports/menu_card"](data)
    $("#menu_card_unit").empty()
    $(".menu_card_unit").show()
    $("#menu_card_unit").append result
    if $("#menu_card_unit").val() != ''
      $("#interval-submit-button").attr("disabled", false)
    else
      $("#interval-submit-button").attr("disabled", true)
    return
  request.error (jqXHR, textStatus, errorThrown) ->
    alert "AJAX Error:" + textStatus
    return

$(document).on "change", ".payment-mode-type",->
  paymentmode = $(this).val()
  from_date = $('#from_date').val()
  to_date = $('#to_date').val()
  unit_id = $("#unit_id").val()
  section_id = $("#section_id").val()
  deliverable_type = $("#deliverable_type").val()
  order_sources = []
  $('.order_sources:checkbox:checked').map ->
    order_sources.push $(this).val()
  href = "/sale_reports/by_date.csv?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&paymentmode=#{paymentmode}"
  
  if $("#deliverable_type").val()=="Section"
    $(".export-by-date-sales-report").prop('href', href+"&section_id=#{section_id}&deliverable_type=#{deliverable_type}&order_sources=#{order_sources}");
    $(".export-by-date-sales-report").prop('href', href+"&section_id=#{section_id}&deliverable_type=#{deliverable_type}&order_sources=#{order_sources}");
  else
    $(".export-by-date-sales-report").prop('href', href+"&deliverable_type=#{deliverable_type}&order_sources=#{order_sources}");
    $(".export-by-date-sales-report").prop('href', href+"&deliverable_type=#{deliverable_type}&order_sources=#{order_sources}");
  href_pdf = "/sale_reports/by_date.pdf?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&paymentmode=#{paymentmode}"    
  if $("#deliverable_type").val()=="Section"
    $(".export-by-date-sales-report_pdf").prop('href',href_pdf+"&section_id=#{section_id}&deliverable_type=#{deliverable_type}&order_sources=#{order_sources}");
  else
    $(".export-by-date-sales-report_pdf").prop('href',href_pdf+"&deliverable_type=#{deliverable_type}&order_sources=#{order_sources}");
  return

# Bill Filtering
$(document).on "click", ".payment-mode-type", ->
  $('.payment-mode-options').prop('checked', false).trigger("change")
  if $(this).val() is "ThirdPartyPayment"
    $('.coupon-payment').hide()
    $('.third-party-payment').show()
  else if $(this).val() is "CouponPayment"
    $('.third-party-payment').hide()
    $('.coupon-payment').show()
  else
    $('.third-party-payment, .coupon-payment').hide()
  return  

$(document).on "change", ".order_sources",->
  paymentmode = $('input:radio[name=paymentmode]:checked').val()
  from_date = $('#from_date').val()
  to_date = $('#to_date').val()
  unit_id = $("#unit_id").val()
  section_id = $("#section_id").val()
  deliverable_type = $("#deliverable_type").val()
  order_sources = []
  $('.order_sources:checkbox:checked').map ->
    order_sources.push $(this).val()
  if $("#deliverable_type").val()=="Section"
    href = "/sale_reports/by_date.csv?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&order_sources=#{order_sources}"
    $(".export-by-date-sales-report").prop('href', href+"&section_id=#{section_id}&deliverable_type=#{deliverable_type}&paymentmode=#{paymentmode}");
    href_pdf = "/sale_reports/by_date.pdf?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&order_sources=#{order_sources}"    
    $(".export-by-date-sales-report_pdf").prop('href',href_pdf+"&section_id=#{section_id}&deliverable_type=#{deliverable_type}&paymentmode=#{paymentmode}");
  else
    href = "/sale_reports/by_date.csv?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&order_sources=#{order_sources}"
    $(".export-by-date-sales-report").prop('href', href+"&deliverable_type=#{deliverable_type}&paymentmode=#{paymentmode}");
    href_pdf = "/sale_reports/by_date.pdf?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&order_sources=#{order_sources}"    
    $(".export-by-date-sales-report_pdf").prop('href',href_pdf+"&deliverable_type=#{deliverable_type}&paymentmode=#{paymentmode}");
  return