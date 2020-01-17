# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->

	$(document).on "change", "#deliverable_type",->
		from_date = $("#from_date").val()
		to_date = $("#to_date").val()
		deliverable_type = $(this).val()
		section_id = $("#section_id").val()
		href = "/comprehensive_sale_reports/bill_by_bill_report.csv?&from_date=#{from_date}&to_date=#{to_date}&deliverable_type=#{deliverable_type}&section_id=#{section_id}"
		$(".unit_ids").each ->
			href = href+"&unit_ids[]="+$(this).val()
		$('.bill_statuses:checkbox:checked').map ->
			bill_statuses.push $(this).val()
			href = href+"&bill_statuses[]="+$(this).val()
		if $('#discountmode').prop("checked") == true
			$('.export-bill-by-bill-sales-report').attr('href', href+"&discountmode=1")
		else
			$('.export-bill-by-bill-sales-report').attr('href', href)
		if $('.bill_validity').prop("checked") == true
			$('.export-bill-by-bill-sales-report').attr('href', href+"&bill_validity=1")
		else
			$('.export-bill-by-bill-sales-report').attr('href', href)
		return

	$(document).on "change", "#section_id",->
		from_date = $("#from_date").val()
		to_date = $("#to_date").val()
		deliverable_type = $("#deliverable_type").val()
		section_id = $(this).val()
		href = "/comprehensive_sale_reports/bill_by_bill_report.csv?&from_date=#{from_date}&to_date=#{to_date}&deliverable_type=#{deliverable_type}&section_id=#{section_id}"
		$(".unit_ids").each ->
			href = href+"&unit_ids[]="+$(this).val()
		$('.bill_statuses:checkbox:checked').map ->
			bill_statuses.push $(this).val()
			href = href+"&bill_statuses[]="+$(this).val()
		if $('#discountmode').prop("checked") == true
			$('.export-bill-by-bill-sales-report').attr('href', href+"&discountmode=1")
		else
			$('.export-bill-by-bill-sales-report').attr('href', href)
		if $('.bill_validity').prop("checked") == true
			$('.export-bill-by-bill-sales-report').attr('href', href+"&bill_validity=1")
		else
			$('.export-bill-by-bill-sales-report').attr('href', href)
		return

	$(document).on "change", "#discountmode",->
		from_date = $("#from_date").val()
		to_date = $("#to_date").val()
		deliverable_type = $("#deliverable_type").val()
		section_id = $("#section_id").val()
		href = "/comprehensive_sale_reports/bill_by_bill_report.csv?&from_date=#{from_date}&to_date=#{to_date}&section_id=#{section_id}"
		$(".unit_ids").each ->
			href = href+"&unit_ids[]="+$(this).val()
		if $(this).prop("checked") == true
			$('.export-bill-by-bill-sales-report').attr('href', href+"&discountmode=1")
		else
			$('.export-bill-by-bill-sales-report').attr('href', href)
		if $('.bill_validity').prop("checked") == true
			$('.export-bill-by-bill-sales-report').attr('href', href+"&bill_validity=1")
		else
			$('.export-bill-by-bill-sales-report').attr('href', href)
		return

	$(document).on "change", ".bill_validity",->
		from_date = $("#from_date").val()
		to_date = $("#to_date").val()
		deliverable_type = $("#deliverable_type").val()
		section_id = $("#section_id").val()
		href = "/comprehensive_sale_reports/bill_by_bill_report.csv?&from_date=#{from_date}&to_date=#{to_date}&section_id=#{section_id}"
		$(".unit_ids").each ->
			href = href+"&unit_ids[]="+$(this).val()
		$('.bill_statuses:checkbox:checked').map ->
			bill_statuses.push $(this).val()
			href = href+"&bill_statuses[]="+$(this).val()
		if $('#discountmode').prop("checked") == true
			$('.export-bill-by-bill-sales-report').attr('href', href+"&discountmode=1")
		else
			$('.export-bill-by-bill-sales-report').attr('href', href)
		if $(this).prop("checked") == true
			$('.export-bill-by-bill-sales-report').attr('href', href+"&bill_validity=1")
		else
			$('.export-bill-by-bill-sales-report').attr('href', href)
		return

	$(document).on "change", ".bill_statuses",->
		from_date = $('#from_date').val()
		to_date = $('#to_date').val()
		section_id = $("#section_id").val()
		deliverable_type = $("#deliverable_type").val()
		href = "/comprehensive_sale_reports/bill_by_bill_report.csv?&from_date=#{from_date}&to_date=#{to_date}&deliverable_type=#{deliverable_type}&section_id=#{section_id}"
		$(".unit_ids").each ->
			href = href+"&unit_ids[]="+$(this).val()
		$('.bill_statuses:checkbox:checked').map ->
			bill_statuses.push $(this).val()
			href = href+"&bill_statuses[]="+$(this).val()
		if $('#discountmode').prop("checked") == true
			$('.export-bill-by-bill-sales-report').attr('href', href+"&discountmode=1")
		else
			$('.export-bill-by-bill-sales-report').attr('href', href)
		if $('.bill_validity').prop("checked") == true
			$('.export-bill-by-bill-sales-report').attr('href', href+"&bill_validity=1")
		else
			$('.export-bill-by-bill-sales-report').attr('href', href)
		return

	return