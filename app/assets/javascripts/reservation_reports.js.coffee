# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
  
$(document).on "change", "#resource_id",->
  resource_id = $(this).val()
  from_date = $(".from_date").val()
  href = "/reservation_reports/reservation_report.csv?&from_date=#{from_date}&resource_id=#{resource_id}"
  $(".export-by-date-reservation-report").prop('href', href);
  return