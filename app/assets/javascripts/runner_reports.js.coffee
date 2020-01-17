# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->

	$(document).on "change", "#delivery_boy_id",->
		delivery_boy_id = $(this).val()
		from_date = $(this).data('from-date')
		to_date = $(this).data('to-date')
		unit_id = $(this).data("unit-id")
		order_status_id = $("#order_status_id").val()
		csv_url = $(this).data("csv-url")
		href = "/runner_reports/#{csv_url}.csv?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&delivery_boy_id=#{delivery_boy_id}"
		$(".export-runner-reports").prop('href', href+"&order_status_id=#{order_status_id}")
		return

	$(document).on "change", "#order_status_id",->
		order_status_id = $(this).val()
		from_date = $(this).data('from-date')
		to_date = $(this).data('to-date')
		unit_id = $(this).data("unit-id")
		delivery_boy_id = $("#delivery_boy_id").val()
		csv_url = $(this).data("csv-url")
		href = "/runner_reports/#{csv_url}.csv?&from_date=#{from_date}&to_date=#{to_date}&unit_id=#{unit_id}&order_status_id=#{order_status_id}"
		$(".export-runner-reports").prop('href', href+"&delivery_boy_id=#{delivery_boy_id}")
		return