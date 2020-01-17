$(document).ready ->
	update_selected_currency = (data) ->
		console.log(data["country_currency_id"])
		$("#currency_multipliler_#{data['country_currency_id']}").text(data["multiplier"])
		$('#currencyModal').modal('toggle');
		Materialize.toast("Currency updated successfully", 3000,'green')
		return
	build_selected_currency_module = (data) ->
		base_currency = $("#add_currency_conversion").data("base-currency")
		multiplier = data['accepted_currency']['multiplier']
		html_str = "<div class='card grey' style='height:30px;padding:5px;'>"
		html_str += "<span class='currency_name'>#{data['accepted_currency']['currency_code']}</span>"
		html_str += "<span style='margin-left:55px;'>"
		html_str += "1 #{data['accepted_currency']['currency_code']}"
		html_str += "<i style='color:green;' class='fa fa-exchange'></i>"
		html_str += "<span id='currency_multipliler_#{data['accepted_currency']['country_currency_id']}'>#{multiplier}</span>" 
		html_str += "#{base_currency}"
		html_str += "</span>"
		html_str += "<span style='float:right;padding:2px;'>"
		html_str += "<button class='m-btn orange m-btn-low-padding open_modal' data-base-currency='#{base_currency}' data-currency-code='#{data['accepted_currency']['currency_code']}' data-currency-id='#{data['accepted_currency']['country_currency_id']}' data-multiplier='#{data['accepted_currency']['multiplier']}' data-selected-currency='#{data['accepted_currency']['currency']}'>"
		html_str += "<i style='font-size:1em;' class='mdi-editor-border-color'></i>"
		html_str += "</button></span>"
		html_str += "</div>"
		$("#selected_currency_panel").append(html_str)
		Materialize.toast("Currency added successfully", 3000,'green')
		$('#currencyModal').modal('toggle');

		return

	$(document).on "click",".open_modal", ->
		flag =true
		multiplier = $(this).data("multiplier")
		base_currency = $(this).data("base-currency")
		selected_currency = $(this).data("selected-currency")
		selected_currency_code = $(this).data("currency-code")
		selected_currency_id  = $(this).data("currency-id")
		if $(this).data("module") == "selection_module"
			$("#currency_final_selection").text("Add currency")
			$("#currency_final_selection").attr("data-module","create")
			$("#selected_currency_panel").find('.currency_name').each ->
				if selected_currency_code == $.trim($(this).text())
					flag = false
					Materialize.toast("Sorry!! currency already selected", 3000,'red')
					return
		else
			$("#currency_final_selection").text("Update currency")
			$("#currency_final_selection").attr("data-module","update")
		if flag == true
			html_str = "<div class='col-sm-5'>" 
			html_str += "<span style='float:left;font-family: monospace; font-size:18px;'>#{selected_currency_code}</span>"
			html_str += "<span style='margin-left:50px;'><i style='color:green;' class='fa fa-exchange fa-3x'></i></span>"
			html_str += "<span style='float:right; font-family: monospace;font-size:18px;'>#{base_currency}</span>"
			html_str += "</div>"
			html_str += "<div class='col-sm-3'>"
			html_str += "<input id='conversion-rate' data-selected-currency-id=#{selected_currency_id} type='number' style='width:80px;' class='form-control' value='#{multiplier}'>"
			html_str += "</div>"
			$("#conversion-module").html(html_str)
			$('#currencyModal').modal('show');

		return
	$(document).on "click","#currency_final_selection", ->
		multiplier = $("#conversion-rate").val()
		currency_id = $("#conversion-rate").data("selected-currency-id")
		if isNaN(multiplier) || multiplier <= 0
			alert("please provide correct input")
		else
			if $(this).attr("data-module") == "create"
				response = ''
				$.ajax(
					async: false,
					url : "/expected_currencies",
					type : "POST",
					dataType: "json",
					data :
						accecpted_currency:
							multiplier:multiplier,
							country_currency_id:currency_id,
							status:true
					).success((data) ->
						build_selected_currency_module(data["data"])
				  ).error((data) ->
				  	alert("some error occured in ajax")
				  )
			else
				$.ajax(
					async: false,
					url : "/expected_currencies/update_multiplier",
					type : "POST",
					dataType: "json",
					data :
						accecpted_currency:
							multiplier:multiplier,
							country_currency_id:currency_id,
							status:true
					).success((data) ->
						update_selected_currency(data["data"]["accepted_currency"])
				  ).error((data) ->
				  	alert("some error occured in ajax")
				  )
		return
	return
