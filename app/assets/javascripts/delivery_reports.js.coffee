# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
	
	$(document).on "keyup", "#delivery_boy_name_filter",->
		from_date = $("#from_date_val").val()
		to_date = $("#to_date_val").val()
		unit_id = $("#unit_id_val").val()
		delivery_boy_name = $(this).val()
		href = "/delivery_reports/delivery_boys_report.csv?unit_id=#{unit_id}&from_date=#{from_date}&to_date=#{to_date}&name_filter=#{delivery_boy_name}"
		$(".delivery-boys-report").prop('href', href);
		return

	return