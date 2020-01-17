# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).on 'click', '#bulk_print_btn', (event)->
	event.preventDefault()
	different_barcode_on_two_level_conf = $("#different_barcode_on_two_level_conf").val()
	if different_barcode_on_two_level_conf != 'enabled'
		$('.bulk_print_checkbox:checkbox:checked').map ->
			rpo = $(this).data('rpo')
			f_l1 = $("#print_btn_#{rpo}").data('site')
			f_l2 = if $("#print_btn_#{rpo}").data('mrp') == null then "000000/-" else $("#print_btn_#{rpo}").data('mrp')
			f_l3 = $("#print_btn_#{rpo}").data('sku')
			b_l1 = if $("#print_btn_#{rpo}").data('mrp') == null then "000000/-" else $("#print_btn_#{rpo}").data('mrp')
			b_l2 = ''
			itemname = $("#print_btn_#{rpo}").data('itemname')
			# itemname = itemname.split(' ').join('_')
			# itemname = itemname.split('_').join(' ')
			count = $("#print_btn_#{rpo}").data("count")
			m_l1 = if $("#print_btn_#{rpo}").data('model-number') == null then "-" else $("#print_btn_#{rpo}").data('model-number')
			s_l1 = if $("#print_btn_#{rpo}").data('size') == null then "-" else $("#print_btn_#{rpo}").data('size')
			c_l1 = if $("#print_btn_#{rpo}").data('color-name') == null then "-" else $("#print_btn_#{rpo}").data('color-name')
			d_l1 = $("#print_btn_#{rpo}").data('created-at')
			mfg_d1 = $("#print_btn_#{rpo}").data('mfg-date')
			batch_no = $("#print_btn_#{rpo}").data('batch-no')
			sale_price = $("#print_btn_#{rpo}").data('sale-price')
			currency = $("#print_btn_#{rpo}").data('currency')
			exp_date = $("#print_btn_#{rpo}").data('exp-date')
			quantity = $("#print_btn_#{rpo}").data('quantity')
			brand_name = $("#print_btn_#{rpo}").data('brand-name')
			p_gender = $("#print_btn_#{rpo}").data('p-gender')
			category_code = $("#print_btn_#{rpo}").data('category-code')

			print_url = "http://localhost:3000/?f-l1=#{f_l1}&f-l2=#{f_l2}&f-l3=#{f_l3}&f-l4=#{f_l3}&b-l1=#{b_l1}&b-l2=#{b_l2}&b-l3=#{f_l3}&b-l4=#{f_l3}&m-l1=#{m_l1}&s-l1=#{s_l1}&c-l1=#{c_l1}&d-l1=#{d_l1}&mfg=#{mfg_d1}&batchno=#{batch_no}&count=#{Math.trunc(count)}&itemname=#{itemname}&sale_price=#{sale_price}&currency=#{currency}&exp_date=#{exp_date}&quantity=#{qty}&brand_name=#{brand_name}&gender=#{p_gender}&category_code=#{category_code}"
			$.ajax
				type: 'GET'
				dataType: 'text'
				url: print_url
				success: (responseData, textStatus, jqXHR) ->
					# alert responseData
					$('#print_modal').modal("hide")
					$("#print_btn_#{rpo}").addClass('green')
					$.ajax
						type: 'PUT'
						data:
							stock_id: rpo
						url: '/stocks/barcode_print_update'
				error: (responseData, textStatus, errorThrown) ->
					alert "Printer server is offline"
					console.log print_url 

	else

		all_barcodes = []
		$('.bulk_print_checkbox:checkbox:checked').map ->
			all_barcodes.push $(this).data('rpo')
		total_barcode = $('.bulk_print_checkbox:checkbox:checked').length
		q = Math.round(total_barcode / 2)

		i = 0
		all_barcodes_index = 0
		while i < q
			j = 0
			two_barcodes = []
			two_rpo = []
			while j < 2
				rpo = all_barcodes[all_barcodes_index]
				# rpo = $('.bulk_print_checkbox').data('rpo')
				f_l1 = $("#print_btn_#{rpo}").data('site')
				f_l2 = if $("#print_btn_#{rpo}").data('mrp') == null then "000000/-" else $("#print_btn_#{rpo}").data('mrp')
				f_l3 = $("#print_btn_#{rpo}").data('sku')
				b_l1 = if $("#print_btn_#{rpo}").data('mrp') == null then "000000/-" else $("#print_btn_#{rpo}").data('mrp')
				b_l2 = ''
				itemname = $("#print_btn_#{rpo}").data('itemname')
				# itemname = itemname.split(' ').join('_')
				# itemname = itemname.split('_').join(' ')
				count = if $("#print_btn_#{rpo}").data('count') == null then "-" else $("#print_btn_#{rpo}").data('count')
				m_l1 = if $("#print_btn_#{rpo}").data('model-number') == null then "-" else $("#print_btn_#{rpo}").data('model-number')
				s_l1 = if $("#print_btn_#{rpo}").data('size') == null then "-" else $("#print_btn_#{rpo}").data('size')
				c_l1 = if $("#print_btn_#{rpo}").data('color-name') == null then "-" else $("#print_btn_#{rpo}").data('color-name')
				d_l1 = $("#print_btn_#{rpo}").data('created-at')
				mfg_d1 = $("#print_btn_#{rpo}").data('mfg-date')
				batch_no = $("#print_btn_#{rpo}").data('batch-no')
				if typeof(count) != 'undefined'
					if j%2==0
						url = "f-l1=#{f_l1}&f-l2=#{f_l2}&f-l3=#{f_l3}&f-l4=#{f_l3}&b-l1=#{b_l1}&b-l2=#{b_l2}&b-l3=#{f_l3}&b-l4=#{f_l3}&m-l1=#{m_l1}&s-l1=#{s_l1}&c-l1=#{c_l1}&d-l1=#{d_l1}&mfg=#{mfg_d1}&batchno=#{batch_no}&count=#{Math.trunc(count)}&itemname=#{itemname}"
					else
						url = "f1-l1=#{f_l1}&f1-l2=#{f_l2}&f1-l3=#{f_l3}&f1-l4=#{f_l3}&b1-l1=#{b_l1}&b1-l2=#{b_l2}&b1-l3=#{f_l3}&b1-l4=#{f_l3}&m1-l1=#{m_l1}&s1-l1=#{s_l1}&c1-l1=#{c_l1}&d1-l1=#{d_l1}&mfg1=#{mfg_d1}&batchno1=#{batch_no}&count1=#{Math.trunc(count)}&itemname1=#{itemname}"
						
					two_barcodes.push url
					two_rpo.push rpo

				j++
				all_barcodes_index++
			b = 0
			url_print = ''
			while b < 2
				if typeof(two_barcodes[b]) != 'undefined'
					if url_print == ''
						url_print += two_barcodes[b]
					else
						url_print += "&#{two_barcodes[b]}"
				b++
			print_url = "http://localhost:3000/?#{url_print}"

			$.ajax
				type: 'GET'
				dataType: 'text'
				url: print_url
				async: false
				success: (responseData, textStatus, jqXHR) ->
					t_r = 0
					while t_r < two_rpo.length
						single_rpo = two_rpo[t_r]
						$("#print_btn_#{single_rpo}").addClass('green')
						$.ajax
							type: 'PUT'
							data:
								stock_id: single_rpo
							url: '/stocks/barcode_print_update'
						t_r++
				error: (responseData, textStatus, errorThrown) ->
					alert "Printer server is offline"
					console.log print_url

			i++


$(document).on "click", ".print-barcodde",->
	sku = $(this).data('sku')
	name = encodeURI($(this).data('name'))
	site_name = $(this).data('site')
	count = $(this).data('count')
	mrp = if $(this).data('mrp') == null then "000000/-" else $(this).data('mrp')
	wt = if $(this).data('wt') == null then "0.0" else $(this).data('wt')
	mc = if $(this).data('mc') == null then "000000/-" else $(this).data('mc')
	wst = if $(this).data('wastage') == null then "0.0" else $(this).data('wastage')
	model_number = encodeURI($(this).data('model-number'))
	size = if $(this).data('size') == null then "-" else $(this).data('size')
	size = encodeURI(size)
	color_name = if $(this).data('color-name') == null then "-" else $(this).data('color-name')
	created_at = $(this).data('created-at')
	mfg_date = $(this).data('mfg-date')
	# batch_no = if $(this).data('batch-no') == null then "-" else $(this).data('batch-no')
	batch_no = $(this).data('batch-no')
	itemname = encodeURI($(this).data('itemname'))
	rpo = $(this).data('rpo')
	sale_price = $(this).data('sale-price')
	currency = $(this).data('currency')
	exp_date = $(this).data('exp-date')
	quantity = encodeURI($(this).data('quantity'))
	brand_name = encodeURI($(this).data('brand-name'))
	p_gender = encodeURI($(this).data('p-gender'))
	category_code = encodeURI($(this).data('category-code'))

	$("#print_count").val(parseInt(count))
	
	$('.bar-mrp').html "MRP : " + mrp
	$('.bar-title').html decodeURI(name)
	$('.bar-weight').html " G : " + wt
	$('.bar-making-cost').html "MC : " + mc + "&nbsp&nbsp&nbsp W : " + wst
	$('.bar-sku').html sku
	$('#radio_by_weight').html("<input class='type_radio' id='type_by_weight' name='type' value='by_weight' type='radio' data-f-l1="+site_name+" data-f-l2="+name+" data-f-l3="+sku+" data-b-l1='G : "+wt+"' data-count="+count+" data-b-l2='MC : "+mc+"      W : "+wst+"'><label for='type_by_weight'></label>")
	$('#radio_by_mrp').html("<input class='type_radio' id='type_by_mrp' name='type' value='by_mrp' type='radio' data-f-l1="+site_name+" data-f-l2='MRP : "+mrp+"' data-f-l3="+sku+" data-b-l1='MRP : "+mrp+"' data-b-l2='' data-count="+count+"><label for='type_by_mrp'></label>")
	$('#radio_by_catalog').html("<input class='type_radio' id='type_by_catalog' name='type' value='by_catalog' type='radio' data-f-l1="+site_name+" data-f-l2='"+mrp+"' data-f-l3="+sku+" data-b-l1='"+mrp+"' data-b-l2='' data-count="+count+" data-m-l1="+model_number+" data-s-l1="+size+" data-c-l1="+color_name+" data-created-at="+created_at+" data-mfg-date="+mfg_date+" data-batch-no="+batch_no+" data-itemname=#{itemname} data-rpo=#{rpo} data-sale-price=#{sale_price} data-currency=#{currency} data-exp-date=#{exp_date} data-quantity=#{quantity} data-brand-name=#{brand_name} data-p-gender=#{p_gender} data-category-code=#{category_code} checked='checked'><label for='type_by_catalog'></label>")
	$('#print_modal').modal("show")

$(document).on "click", ".print-barcode",->
	if $('input:radio[name=type]:checked').length == 0
		Materialize.toast("Please select a pattarn first.", 5000)
	else
		f_l1 = $('input:radio[name=type]:checked').data('f-l1')
		f_l2 = $('input:radio[name=type]:checked').data('f-l2')
		f_l3 = $('input:radio[name=type]:checked').data('f-l3')
		f_l4 = $('input:radio[name=type]:checked').data('f-l4')
		b_l1 = $('input:radio[name=type]:checked').data('b-l1')
		b_l2 = $('input:radio[name=type]:checked').data('b-l2')
		itemname = decodeURI($('input:radio[name=type]:checked').data('itemname'))
		# count = $('input:radio[name=type]:checked').data('count')
		count = $("#print_count").val()
		if count.length == 0
			count = 1
		m_l1 = decodeURI($('input:radio[name=type]:checked').data('m-l1'))
		s_l1 = decodeURI($('input:radio[name=type]:checked').data('s-l1'))
		c_l1 = $('input:radio[name=type]:checked').data('c-l1')
		d_l1 = $('input:radio[name=type]:checked').data('created-at')
		mfg_d1 = $('input:radio[name=type]:checked').data('mfg-date')
		batch_no = $('input:radio[name=type]:checked').data('batch-no')
		sale_price = $('input:radio[name=type]:checked').data('sale-price')
		currency = $('input:radio[name=type]:checked').data('currency')
		exp_date = $('input:radio[name=type]:checked').data('exp-date')
		qty = decodeURI($('input:radio[name=type]:checked').data('quantity'))
		brand_name = decodeURI($('input:radio[name=type]:checked').data('brand-name'))
		p_gender = decodeURI($('input:radio[name=type]:checked').data('p-gender'))
		category_code = decodeURI($('input:radio[name=type]:checked').data('category-code'))

		print_url = "http://localhost:3000/?f-l1=#{f_l1}&f-l2=#{f_l2}&f-l3=#{f_l3}&f-l4=#{f_l3}&b-l1=#{b_l1}&b-l2=#{b_l2}&b-l3=#{f_l3}&b-l4=#{f_l3}&m-l1=#{m_l1}&s-l1=#{s_l1}&c-l1=#{c_l1}&d-l1=#{d_l1}&mfg=#{mfg_d1}&batchno=#{batch_no}&count=#{Math.trunc(count)}&production_itemname=#{itemname}&sale_price=#{sale_price}&currency=#{currency}&exp_date=#{exp_date}&quantity=#{qty}&brand_name=#{brand_name}&gender=#{p_gender}&category_code=#{category_code}"
		rpo = $('input:radio[name=type]:checked').data('rpo')
		# alert print_url
		$.ajax
			type: 'GET'
			dataType: 'text'
			url: print_url
			success: (responseData, textStatus, jqXHR) ->
				# alert responseData
				$('#print_modal').modal("hide")
				$("#print_btn_#{rpo}").addClass('green')
				$.ajax
					type: 'PUT'
					data:
						stock_id: rpo
					url: '/stocks/barcode_print_update'
			error: (responseData, textStatus, errorThrown) ->
				alert "Printer server is offline"
				console.log print_url
		return

$(document).ready ->
	$(document).on "keyup", '.product-total-wt', ->
		totalPrice = parseFloat($(this).val())
		productId = $(this).data('product-id')
		productQty = parseFloat($(".input_quantity_of_#{productId}").val())
		productQty = 0 if isNaN(productQty)
		landingPrice = (totalPrice/productQty).toFixed(2)
		$(".landing-price-#{productId}").val(landingPrice)
		return
	$("#details").hide()
	$(document).on "change", '.product-sku', ->
		new_sku = $(this).val()
		i = 0
		$(".test .product-sku").each (index) ->
			sku = $(this).val()
			if new_sku == sku
				i++
		if i > 1
			Materialize.toast("SKU you entered is already given.", 5000)
			$('.send_now_order').prop('disabled', true)
		else
			$('.send_now_order').prop('disabled', false)
		return

	$(document).on "click", '#po_receive_add_to_stock', ->
		invoice_amount = $("#invoice_amount").val()
		po_total_amount = $(".po_total_amount").html()
		invoice_date_status = $("#invoice_date_status").val()
		if invoice_date_status.length > 0
			invoice_date = $("#invoice_date").val()
			if invoice_date.length == 0
				Materialize.toast("Enetr Invoice Date", 3000,'red')
				$("#invoice_date").addClass('red')
				return false
		if parseFloat(invoice_amount) == parseFloat(po_total_amount)
			if !window.confirm('Do you want to continue?')
				return false
		else
			if !window.confirm('PO total amount and invoice amount mismatched. Do you want to continue?')
				return false
		return

	# search by sku during Purchase Order receive

	$('#search_by_sku_po').keypress (e) ->
		if e.which == 13
			$('#search_by_sku_po_btn').click()
		return

	$(document).on 'click', '#invoice_date', (event)->  
		$("#invoice_date").removeClass('red')
		return  

	# $("#search_by_sku_po").click ->
	#   $("#search_by_sku_po").val("")
	#   return
	
	$(document).on 'click', '#search_by_sku_po_btn', (event)->
		event.preventDefault()
		search_text = $("#search_by_sku_po").val()
		$(".product-sku").reverse().each () ->
			sku = $(this).val()
			# if sku == search_text
			if sku.indexOf(search_text) != -1
				$(this).addClass('green')
				# $(this).focus()
				$(this).parent('td').parent('tr').children('td').find('.pro-mrp').focus()
				
				$(this).parent('td').parent('tr').children('td').find('.product_name').addClass('green')
			else
				$(this).removeClass('green')
				$(this).parent('td').parent('tr').children('td').find('.product_name').removeClass('green')
			if search_text == ''
				$(this).removeClass('green')
				$(this).parent('td').parent('tr').children('td').find('.product_name').removeClass('green')
			setTimeout (->
				$("#search_by_sku_po").val("")
				return
			), 2500
		return

	$(document).on "keyup", ".landing-price",->
		product_id = $(this).data("product-id")
		pom_id = $(this).data("pom-id")
		uid = $(this).data("uid")
		landing_price = parseFloat($("input[name=pro_price_#{pom_id}_#{uid}]").val())
		sale_price = parseFloat($("input[name=retail_price_#{pom_id}_#{uid}]").val())
		mrp = parseFloat($("input[name=pro_mrp_#{pom_id}_#{uid}]").val())
		landing_price = 0 if isNaN(landing_price)
		sale_price = 0 if isNaN(sale_price)
		mrp = 0 if isNaN(mrp)
		if landing_price > sale_price
			Materialize.toast("Landing price should be less than Sale price.", 3000,'red')
			#$(this).addClass('red')
		else
			#$(this).removeClass('red')
		if landing_price > mrp
			Materialize.toast("Landing price should be less than Mrp.", 3000,'red')
			#$(this).css('color', 'red')
		else
			#$(this).css('color', '')
		return

	$(document).on "keyup", ".sale-price",->
		product_id = $(this).data("product-id")
		pom_id = $(this).data("pom-id")
		uid = $(this).data("uid")
		landing_price = parseFloat($("input[name=pro_price_#{pom_id}_#{uid}]").val())
		sale_price = parseFloat($("input[name=retail_price_#{pom_id}_#{uid}]").val())
		mrp = parseFloat($("input[name=pro_mrp_#{pom_id}_#{uid}]").val())
		landing_price = 0 if isNaN(landing_price)
		sale_price = 0 if isNaN(sale_price)
		mrp = 0 if isNaN(mrp)

		if landing_price > sale_price
			Materialize.toast("Sale price should be greater than Landing price.", 3000,'red')
			#$(this).addClass('red')
		else
			#$(this).removeClass('red')
		if sale_price > mrp
			Materialize.toast("Sale price should be less than Mrp.", 3000,'red')
			#$(this).css('color', 'red')
		else
			#$(this).css('color', '')

		discount_on_mrp = 100 - ((sale_price*100)/mrp)
		$(".discount_on_mrp_#{product_id}_#{uid}").val(discount_on_mrp)

		calculate_profit product_id,uid

		return

	#mrp
	$(document).on "keyup", ".purchase-cost",->
		product_id = $(this).data("product-id")
		pom_id = $(this).data("pom-id")
		uid = $(this).data("uid")
		landing_price = parseFloat($("input[name=pro_price_#{pom_id}_#{uid}]").val())
		sale_price = parseFloat($("input[name=retail_price_#{pom_id}_#{uid}]").val())
		mrp = parseFloat($("input[name=pro_mrp_#{pom_id}_#{uid}]").val())
		landing_price = 0 if isNaN(landing_price)
		sale_price = 0 if isNaN(sale_price)
		mrp = 0 if isNaN(mrp)
		if landing_price > mrp
			Materialize.toast("Landing price should be less than Mrp.", 3000,'red')
			#$(this).addClass('red')
		else
			#$(this).removeClass('red')
		if sale_price > mrp
			Materialize.toast("Sale price should be less than Mrp.", 3000,'red')
			#$(this).css('color', 'red')
		else
			#$(this).css('color', '')
		return

	$(document).on "click", ".checkbox-parent-toggle",->
		if (this.checked)
			$(".checkbox-child").prop('checked', true) 
			$(".check-input").prop('required', true)    
		else
			$(".checkbox-child").prop('checked', false)
			$(".check-input").prop('required', false)
		return

	$(document).on "click", ".checkbox-child",->
		id = $(this).attr('data-po-id')
		uid = $(this).attr('data-uid')
		if (this.checked)
			$(".check-input-"+id+"-"+uid).prop('required', true)     
		else
			$(".check-input-"+id+"-"+uid).prop('required', false)
		return  

	$(document).on "click", ".stock_purchase_received",->
		if($(this).is(':checked'))
			po_id = $(this).data('po-id')
			uid = $(this).data("uid")
			metum_id = "#{po_id}_#{uid}"
			$(".color_size_#{metum_id}").each ->
				product_id = $(this).data("product-id")
				color_id = $(this).data("color-id") 
				size_id = $(this).data("size-id")
				quantity = $(this).val()
				if $(".checked_product_color_size_#{metum_id}_#{color_id}_#{size_id}").length
					$(".product_color_size_quantity_#{metum_id}_#{color_id}_#{size_id}").val quantity
				else  
					contentStr = "<input type='checkbox' class='checked_product_color_size_#{metum_id}_#{color_id}_#{size_id}' name='checked_raw_color_size_product_#{metum_id}[]' value='#{color_id}_#{size_id}' checked>"
					contentStr += "<input type='hidden' class='product_color_size_quantity_#{metum_id}_#{color_id}_#{size_id}' name='product_color_size_quantity_#{metum_id}_#{color_id}_#{size_id}' value='#{quantity}'>"
					$(".hold_color_size_#{metum_id}").prepend(contentStr) 
		return

	$(document).on "keyup",".product_color_size", ->
		amount = 0
		metum_id = $(this).data("metum-id")
		$(".color_size_#{metum_id}").each ->
			product_id = $(this).data("product-id")
			color_id = $(this).data("color-id")   
			size_id = $(this).data("size-id")
			quantity = $(this).val()
			if $(this).val().length
				amount += parseFloat($(this).val())
			$(".input_quantity_of_#{metum_id}").val(amount)
			if $(".checked_product_color_size_#{metum_id}_#{color_id}_#{size_id}").length
				$(".product_color_size_quantity_#{metum_id}_#{color_id}_#{size_id}").val quantity
			else  
				contentStr = "<input type='checkbox' class='checked_product_color_size_#{metum_id}_#{color_id}_#{size_id}' name='checked_raw_color_size_product_#{metum_id}[]' value='#{color_id}_#{size_id}' checked>"
				contentStr += "<input type='hidden' class='product_color_size_quantity_#{metum_id}_#{color_id}_#{size_id}' name='product_color_size_quantity_#{metum_id}_#{color_id}_#{size_id}' value='#{quantity}'>"
				$(".hold_color_size_#{metum_id}").prepend(contentStr) 
		return  

	############ Add more rows during stock purchase receive ############

	$(document).on "click", ".add_product_row", ->



		u_ids = []
		$(".stock_purchase_received").each ->
			u = parseInt($(this).data('uid'))
			u = 0 if isNaN(u)
			u_ids.push u
		max_uid = Math.max.apply(Math,u_ids)


		meta_id = $(this).attr('data-meta-id')
		# j = $(this).attr("data-j")
		# data_u = $(this).attr("data-j")
		j = max_uid
		product_unit = $(this).attr("data-product-unit")
		# old_j = j
		old_j = $(this).attr("data-j")
		product_id = $(this).attr("data-product-id")
		total_count = $(this).attr("data-total-count")
		total_count++
		class_pattern_1 = "#{meta_id}-#{old_j}"
		class_pattern_2 = "#{product_id}-#{old_j}"
		class_pattern_3 = "#{product_id}_#{old_j}"
		class_pattern_4 = "#{meta_id}_#{old_j}"
		class_pattern_with_product_unit = "#{product_id}_#{product_unit}_#{old_j}"
		price_wot_class_pattern_old = "price-wot-#{class_pattern_2}"
		name_pattern = "#{meta_id}_#{old_j}"
		checkbox_value = "#{meta_id}_#{old_j}"
		checkbox_id = "#{meta_id}-#{old_j}"
		checkbox_label = "#{meta_id}-#{old_j}"
		accordion_href_pattern = "#{meta_id}_#{old_j}"
		tr_1 = $(this).closest(".product_receive_tr_#{meta_id}_#{old_j}")
		accordion_tr = $(this).closest(".product_receive_tr_#{meta_id}_#{old_j}").next("tr")
		cloned_tr_1 = tr_1.clone()
		cloned_accordion_tr = accordion_tr.clone()
		accordion_tr.after(cloned_tr_1)
		accordion_tr.next('tr').after(cloned_accordion_tr)
		j++
		# data_u++

		$(this).html('')

		############# cloned_tr_1 ##############

		$(cloned_tr_1).removeClass("product_receive_tr_#{meta_id}_#{old_j}").addClass("product_receive_tr_#{meta_id}_#{j}")

		aria_controls = $(cloned_tr_1).find("td[aria-controls]").attr("aria-controls")
		aria_controls_pattern = "#{meta_id}_#{old_j}"
		new_aria_controls = aria_controls.replace("#{aria_controls_pattern}","#{meta_id}_#{j}")
		$(cloned_tr_1).find("td[aria-controls]").attr("aria-controls",new_aria_controls)

		$(cloned_tr_1).find("td").find("input[data-uid]").attr("data-uid",j)
		$(cloned_tr_1).find("td").find("select[data-uid]").attr("data-uid",j)
		$(cloned_tr_1).find("td").find("input[data-counter]").attr("data-counter",j)
		$(document).find("td").find("input[data-total-count]").attr("data-total-count",total_count)
		$('.add_product_row').attr("data-total-count",total_count)

		################ cloned_tr_1 color name select box id and name value change ################
		
		color_size_name_select_id_name_pattern = "#{meta_id}_#{old_j}"
		
		color_name_select_id = $(cloned_tr_1).find("td").find("select[id=color_name_#{color_size_name_select_id_name_pattern}]").attr("id")
		if typeof(color_name_select_id)!= "undefined"
			new_color_name_select_id = color_name_select_id.replace("#{color_size_name_select_id_name_pattern}","#{meta_id}_#{j}")
			$(cloned_tr_1).find("td").find("select[id=color_name_#{color_size_name_select_id_name_pattern}]").attr("id",new_color_name_select_id)

		size_select_id = $(cloned_tr_1).find("td").find("select[id=size_#{color_size_name_select_id_name_pattern}]").attr("id")
		if typeof(size_select_id)!= "undefined"
			new_size_select_id = size_select_id.replace("#{color_size_name_select_id_name_pattern}","#{meta_id}_#{j}")
			$(cloned_tr_1).find("td").find("select[id=size_#{color_size_name_select_id_name_pattern}]").attr("id",new_size_select_id)

		color_name_select_name = $(cloned_tr_1).find("td").find("select[name=color_name_#{color_size_name_select_id_name_pattern}]").attr("name")
		if typeof(color_name_select_name)!= "undefined"
			new_color_name_select_name = color_name_select_name.replace("#{color_size_name_select_id_name_pattern}","#{meta_id}_#{j}")
			$(cloned_tr_1).find("td").find("select[name=color_name_#{color_size_name_select_id_name_pattern}]").attr("name",new_color_name_select_name)

		size_select_name = $(cloned_tr_1).find("td").find("select[name=size_#{color_size_name_select_id_name_pattern}]").attr("name")
		if typeof(size_select_name)!= "undefined"
			new_size_select_name = size_select_name.replace("#{color_size_name_select_id_name_pattern}","#{meta_id}_#{j}")
			$(cloned_tr_1).find("td").find("select[name=size_#{color_size_name_select_id_name_pattern}]").attr("name",new_size_select_name)

		$(cloned_tr_1).find('td').each (index,item) ->

			################ cloned_tr_1 name change ################

			if typeof($(item).find("input[name=pro_qty_#{name_pattern}]").attr("name")) != "undefined"
				input_name_pro_qty =  $(this).find("input[name=pro_qty_#{name_pattern}]").attr("name")
				new_input_name_pro_qty = input_name_pro_qty.replace("pro_qty_#{name_pattern}","pro_qty_#{meta_id}_#{j}")
				$(this).find("input[name=pro_qty_#{name_pattern}]").attr("name",new_input_name_pro_qty)

			if typeof($(item).find("input[name=addon_remarks_#{name_pattern}]").attr("name")) != "undefined"
				input_name_addon_remarks =  $(this).find("input[name=addon_remarks_#{name_pattern}]").attr("name")
				new_input_name_addon_remarks = input_name_addon_remarks.replace("addon_remarks_#{name_pattern}","addon_remarks_#{meta_id}_#{j}")
				$(this).find("input[name=addon_remarks_#{name_pattern}]").attr("name",new_input_name_addon_remarks)

			if typeof($(item).find("input[name*=#{name_pattern}]").attr("name")) != "undefined"
				input_name = $(this).find("input[name*=#{name_pattern}]").attr("name")
				new_input_name = input_name.replace("#{name_pattern}","#{meta_id}_#{j}")
				$(this).find("input[name*=#{name_pattern}]").attr("name",new_input_name)

			#console.log $(this).find("input[name=addon_remarks_#{name_pattern}]").attr("name")

			################ cloned_tr_1 class_name change ################

			if typeof($(item).find("input[class*=#{class_pattern_1}]").attr("class")) != "undefined"
				input_class_name_1 = $(item).find("input[class*=#{class_pattern_1}]").attr("class")
				single_input_class_name_1 = input_class_name_1.split(' ')
				single_input_class_name_1.forEach (item_class_1) ->
					if item_class_1.indexOf("#{class_pattern_1}") > -1
						new_item_class_1 = item_class_1.replace("#{class_pattern_1}","#{meta_id}-#{j}")
						$(item).find("input[class*=#{class_pattern_1}]").removeClass("#{item_class_1}").addClass("#{new_item_class_1}")

			if typeof($(item).find("input[class*=#{class_pattern_2}]").attr("class")) != "undefined"
				input_class_name_2 = $(item).find("input[class*=#{class_pattern_2}]").attr("class")
				single_input_class_name_2 = input_class_name_2.split(' ')
				single_input_class_name_2.forEach (item_class_2) ->
					if item_class_2.indexOf("#{class_pattern_2}") > -1
						new_item_class_2 = item_class_2.replace("#{class_pattern_2}","#{product_id}-#{j}")
						$(item).find("input[class*=#{class_pattern_2}]").removeClass("#{item_class_2}").addClass("#{new_item_class_2}")

			price_wot_class_pattern_new = "price-wot-#{product_id}-#{j}"
			$(item).find("input[class*=#{price_wot_class_pattern_old}]").removeClass("#{price_wot_class_pattern_old}").addClass("#{price_wot_class_pattern_new}")

			if typeof($(item).find("input[class*=#{class_pattern_3}]").attr("class")) != "undefined"
				input_class_name_3 = $(item).find("input[class*=#{class_pattern_3}]").attr("class")
				single_input_class_name_3 = input_class_name_3.split(' ')
				single_input_class_name_3.forEach (item_class_3) ->
					if item_class_3.indexOf("#{class_pattern_3}") > -1
						new_item_class_3 = item_class_3.replace("#{class_pattern_3}","#{product_id}_#{j}")
						$(item).find("input[class*=#{class_pattern_3}]").removeClass("#{item_class_3}").addClass("#{new_item_class_3}")

			if typeof($(item).find("input[class*=#{class_pattern_4}]").attr("class")) != "undefined"
				input_class_name_4 = $(item).find("input[class*=#{class_pattern_4}]").attr("class")
				single_input_class_name_4 = input_class_name_4.split(' ')
				single_input_class_name_4.forEach (item_class_4) ->
					if item_class_4.indexOf("#{class_pattern_4}") > -1
						new_item_class_4 = item_class_4.replace("#{class_pattern_4}","#{meta_id}_#{j}")
						$(item).find("input[class*=#{class_pattern_4}]").removeClass("#{item_class_4}").addClass("#{new_item_class_4}")
			
			if typeof($(item).find("input[class*=#{class_pattern_with_product_unit}]").attr("class")) != "undefined"
				input_class_name_with_product_unit = $(item).find("input[class*=#{class_pattern_with_product_unit}]").attr("class")
				single_input_class_name_with_product_unit = input_class_name_with_product_unit.split(' ')
				single_input_class_name_with_product_unit.forEach (item_class_with_product_unit) ->
					if item_class_with_product_unit.indexOf("#{class_pattern_with_product_unit}") > -1
						new_item_class_with_product_unit = item_class_with_product_unit.replace("#{class_pattern_with_product_unit}","#{product_id}_#{product_unit}_#{j}")
						$(item).find("input[class*=#{class_pattern_with_product_unit}]").removeClass("#{item_class_with_product_unit}").addClass("#{new_item_class_with_product_unit}")


			################ cloned_tr_1 checkbox related changes ################

			if typeof($(item).find("input[value*=#{checkbox_value}]").attr("value")) != "undefined"
				prev_checkbox_value = $(this).find("input").attr("value")
				#console.log prev_checkbox_value
				new_checkbox_value = prev_checkbox_value.replace("#{checkbox_value}","#{meta_id}_#{j}")
				$(this).find("input").attr("value",new_checkbox_value)

			if typeof($(item).find("input[id*=#{checkbox_id}]").attr("id")) != "undefined"
				prev_checkbox_id = $(this).find("input").attr("id")
				#console.log prev_checkbox_id
				new_checkbox_id = prev_checkbox_id.replace("#{checkbox_id}","#{meta_id}-#{j}")
				$(this).find("input").attr("id",new_checkbox_id)

			if typeof($(item).find("label[for*=#{checkbox_label}]").attr("for")) != "undefined"
				prev_checkbox_label = $(this).find("label").attr("for")
				#console.log prev_checkbox_label
				new_checkbox_label = prev_checkbox_label.replace("#{checkbox_label}","#{meta_id}-#{j}")
				$(this).find("label").attr("for",new_checkbox_label)
				#console.log $(this).find("label").attr("for")

			################ cloned_tr_1 href change accordion view ################

			if typeof($(this).attr("href"))!= "undefined"
				prev_accordion_href = $(this).attr("href")
				if prev_accordion_href.indexOf("#{accordion_href_pattern}") > -1
					new_accordion_href = prev_accordion_href.replace("#{accordion_href_pattern}","#{meta_id}_#{j}")
					$(this).attr("href","#{new_accordion_href}")

			################ cloned_tr_1 j value change ################

			new_j = $(item).find('div').attr("data-j",j)
			if typeof(new_j)!="undefined"
				$(item).find('div').attr("data-j",j)

			# tax_serial_1
			# if typeof($(item).find("input[class*=_#{old_j}]").attr("class")) != "undefined"
			#   $(item).find("input[class*=_#{old_j}]").attr("class").split(' ').forEach (item_class) ->
			#     if item_class.indexOf("_#{old_j}") > -1
			#       $(item).find("input[class*=_#{old_j}]").removeClass("#{item_class}").addClass(item_class.replace("_#{old_j}","_#{j}"))

			if typeof($(item).find("input[class*=tax_serial_#{old_j}]").attr("class")) != "undefined"
				$(item).find("input[class*=tax_serial_#{old_j}]").attr("class").split(' ').forEach (item_class) ->
					if item_class == "tax_serial_#{old_j}"
						$(item).find("input[class*=tax_serial_#{old_j}]").removeClass("#{item_class}").addClass(item_class.replace("#{old_j}","#{j}"))

			if typeof($(item).find("input[class*=hidden_sales_percentage_#{class_pattern_3}]").attr("class")) != "undefined"
				$(item).find("input[class*=#{class_pattern_3}]").attr("class").split(' ').forEach (item_class) ->
					if item_class.indexOf("#{class_pattern_3}") > -1
						$(item).find("input[class*=#{class_pattern_3}]").removeClass("#{item_class}").addClass(item_class.replace("#{class_pattern_3}","#{product_id}_#{j}"))

			return

		$(cloned_tr_1).find("div[id=tax-input-container-#{product_id}-#{old_j}]").attr("id","tax-input-container-#{product_id}-#{j}")
		
		############ cloned_accordion_tr ##############

		$(cloned_accordion_tr).attr("id","stock_purchase_order_collapse_#{meta_id}_#{j}")
		$(cloned_accordion_tr).find("td").find("input[data-uid]").attr("data-uid",j)
		
		accordion_input_class_pattern = "#{meta_id}_#{old_j}"
		
		$(cloned_accordion_tr).find('td').each (accordion_index,accordion_item) ->
			if typeof($(accordion_item).find("input[class*=#{accordion_input_class_pattern}]").attr("class")) != "undefined"
				accordion_item_class = $(this).find("input").attr("class").split(' ')
				#console.log accordion_item_class
				accordion_item_class.forEach (accordion_single_item_class) ->
					if accordion_single_item_class.indexOf("#{accordion_input_class_pattern}") > -1
						new_accordion_item_class = accordion_single_item_class.replace("#{accordion_input_class_pattern}","#{meta_id}_#{j}")            
						$(accordion_item).find("input[class*=#{accordion_input_class_pattern}]").removeClass("#{accordion_single_item_class}").addClass("#{new_accordion_item_class}")
			if typeof($(accordion_item).find("input").attr("data-metum-id")) != "undefined"
				$(this).find("input").attr("data-metum-id","#{meta_id}_#{j}")
			return

		aria_labelledby_accordion = $(cloned_accordion_tr).attr("aria-labelledby")
		aria_label_pattern = "#{meta_id}_#{old_j}"
		new_aria_laelledby_accordion = aria_labelledby_accordion.replace("#{aria_label_pattern}","#{meta_id}_#{j}")
		$(cloned_accordion_tr).attr("aria-labelledby",new_aria_laelledby_accordion)

		hold_color_size_class_pattern = "#{meta_id}_#{old_j}"
		#console.log $(".hold_color_size_#{hold_color_size_class_pattern}").attr("class")
		hold_class_contentStr = "<div class='hold_color_size hold_color_size_#{meta_id}_#{j}'></div>"
		$(".hold_color_size_#{hold_color_size_class_pattern}").append(hold_class_contentStr)

		return

	############ Stock Purchase Functionalities #############
	$(document).on "click", ".tax_class", ->
		product = $(this).data("product-id")
		tax_id = $(this).data("tax-id")
		uid = $(this).data('uid')
		$("#tax_class_#{tax_id}_#{product}").show()
		if (this.checked)
			$(".tax_class_input_#{tax_id}_#{product}_#{uid}").show()
			$(".tax_class_input_#{tax_id}_#{product}_#{uid}").prop('required', true)    
			$(".tax_class_input_#{tax_id}_#{product}_#{uid}").val("")
		else
			$(".tax_class_input_#{tax_id}_#{product}_#{uid}").hide()
			$(".tax_class_input_#{tax_id}_#{product}_#{uid}").prop('required', false)    
		return

	$(document).on "keyup", ".landing-price", ->
		product_id = $(this).data("product-id")
		uid = $(this).data("uid")
		landing_price = $(this).val()
		landing_price = 0 if isNaN(landing_price)
		$(".mrp-#{product_id}-#{uid}").val(landing_price)
		calculate_price_wot product_id,uid
		return

	$(document).on "keyup", ".bulk-receive", ->
		product_id = $(this).data("product-id")
		allowed_units = $(this).data("allowed-units").split(',')
		multipliers = $(this).data("unit-multipliers").split(',')
		raw_qty = $(this).val().split('+')
		# Processing raw quantity description
		total_weight = parseFloat(0)
		_.each raw_qty, (data, idx) ->
			weight = data.split(" ")
			unit = weight[weight.length - 1]
			if $.inArray(unit, allowed_units) != -1
				# Fetching multilier
				multiplier =  parseFloat(multipliers[allowed_units.indexOf(unit)])
				# Weight ARRAY
				weight_arr = weight[weight.length - 2].split('x')
				unit_weight = parseFloat(1)
				_.each weight_arr, (weight, idy) ->
					unit_weight = unit_weight * parseFloat(weight)
				unit_weight = unit_weight * multiplier
				total_weight = total_weight + unit_weight
		$(".quantity-#{product_id}").val(total_weight)
		return  

	# $(document).on "keyup", ".landing-price", ->
	#   product_id = $(this).data("product-id")
	#   uid = $(this).data("uid")
	#   landing_price = $(this).val()
	#   landing_price = 0 if isNaN(landing_price)
	#   $(".mrp-#{product_id}-#{uid}").val(landing_price)
	#   calculate_price_wot product_id
	#   return

	$(document).on "change" , '.checkbox-child' , ->
		if(this.checked) 
			product_id = $(this).data("product-id")
			uid = $(this).data("uid")
			landing_price = $(".landing-price-#{product_id}-#{uid}").val()
			landing_price = 0 if isNaN(landing_price)
			$(".mrp-#{product_id}-#{uid}").val(landing_price) 
			$(".sales_percentage_#{product_id}_#{uid}").prop('disabled', false);   
			calculate_price_wot product_id,uid
			calculate_price_wt product_id,uid
			return

	$(document).on "keyup", ".product-qty", ->
		product_id = $(this).data("product-id")
		uid = $(this).data("uid")
		calculate_price_wot product_id,uid
		return
	
	$(document).on 'change', '#payment_mode', (evt) ->
		if $(this).val() == "cheque"
			$("#cheque_details").show()
			$("#cheque_details").attr('disabled', false)
			$("#neft_details").hide()
			$("#neft_details").attr('disabled', true)
		else if $(this).val() == "neft"
			$("#neft_details").attr('disabled', false)
			$("#neft_details").show()
			$("#cheque_details").hide()
			$("#cheque_details").attr('disabled', true)
		else
			$("#neft_details").hide()
			$("#neft_details").attr('disabled', true)
			$("#cheque_details").hide()
			$("#cheque_details").attr('disabled', true)
			
		return

	$(document).on "click keyup change", ".purchase_input", ->
		product_id = $(this).data("product-id")
		uid = $(this).data("uid")
		total_tax = 0
		calculate_product_qty product_id,uid
		calculate_price_wot product_id,uid
		calculate_price_wt product_id,uid
		return

	$(document).on "click keyup", ".smart_input", ->
		product_id = $(this).data("product-id")
		uid = $(this).data("uid")

		calculate_product_qty product_id,uid

		if !$(this).hasClass('smart_purchase_cost')
			calculate_purchase_price product_id,uid
		calculate_landing_price product_id,uid
		calculate_selling_price product_id,uid

		# calculate_price_wot product_id,uid
		# calculate_price_wt product_id,uid
		landing_price = parseFloat($(".landing-price-#{product_id}-#{uid}").val())
		console.log("landing price : #{landing_price}")
		landing_price = 0 if isNaN(landing_price)
		total_qty = parseFloat($(".quantity-#{product_id}-#{uid}").val())
		total_qty = 0 if isNaN(total_qty)
		total_price_wt = landing_price * total_qty
		total_price_wt = 0 if isNaN(total_price_wt)


		$(".product_price_wt_#{product_id}_#{uid}").val(total_price_wt)

		po_total = parseFloat(0)
		$('.stock_purchase_received:checkbox:checked').map ->
			p_id = $(this).data('product-id')
			u = $(this).data('uid')
			total_amount = parseFloat($(".product_price_wt_#{p_id}_#{u}").val())
			total_amount = 0 if isNaN(total_amount)
			po_total += total_amount
			po_total = Math.round(po_total) 
			po_total = 0 if isNaN(po_total)
		$(".po_total_amount").html(po_total)
		return

	$(document).on "click keyup", ".landing_price_calculation", ->
		calculate_all_landing_price()
		return

	$(document).on "click keyup", ".purchase-qty", ->
		total_cost = 0
		val = $(this).val()
		cost = $(".purchase-cost").val()
		total_cost = val * cost
		return  

	$(document).on "change", ".product-input-unit", ->
		product_id = $(this).data("product-id")
		unit_input = $(this).val()
		unit_input = unit_input.split("__")
		if unit_input[0] > 0
			if $(".input-line-#{product_id}-#{unit_input[0]}").length
				Materialize.toast("#{unit_input[1]} already selected.", 3000, 'rounded')
			else
				input_str = "
						<div class='row margin-l-r-none input-line-#{product_id}-#{unit_input[0]}'>
						<div class='col-lg-2 padding-l-r-none'>
							<input type='checkbox' name='input_quantity_#{product_id}[]' value='#{unit_input[0]}' class='purchase_input filled-in input_unit_of_#{product_id}' data-product-id='#{product_id}' data-multiplier='#{unit_input[2]}' data-unit='#{unit_input[1]}' id='input-unit-of-#{product_id}-#{unit_input[1]}' checked>
							<label for='input-unit-of-#{product_id}-#{unit_input[1]}'></label>
						</div>
						<div class='col-lg-8 padding-l-r-none'>
							<input type='text' name='input_quantity_#{product_id}_#{unit_input[0]}' data-product-id='#{product_id}' placeholder='Enter quantity' class='allow-numeric-only form-control margin-t-b-0 purchase_input validate input_quantity_of_#{product_id}_#{unit_input[1]}'>
						</div>
						<div class='col-lg-2 padding-l-r-none'>
							<br>
							#{unit_input[1]}
						</div></div>      
				"
			$("#input-quantities-#{product_id}").append(input_str)
		return
	
	# Calculating product quantity
	calculate_product_qty = (product_id,uid) ->
		total_qty = parseFloat(0)
		total_free_qty = parseFloat(0)
		qty_sum = parseFloat(0)
		$(".input_unit_of_#{product_id}_#{uid}").each (index) ->
			if ($(this).is ":checked")
				unit = $(this).data("unit")
				multiplier = parseFloat($(this).data("multiplier"))
				uqty = parseFloat($(".input_quantity_of_#{product_id}_#{unit}_#{uid}").val())
				uqty = 0 if isNaN(uqty)
				total_qty = parseFloat(total_qty) + (uqty * multiplier)
				
				fqty = parseFloat($(".free_quantity_#{product_id}_#{uid}").val())
				fqty = 0 if isNaN(fqty)
				total_free_qty = parseFloat(total_free_qty) + (fqty * multiplier)
				
				qty_sum = total_qty + total_free_qty

		# $(".quantity-#{product_id}-#{uid}").val(total_qty)
		$(".quantity-#{product_id}-#{uid}").val(qty_sum)
		return

	# $(document).on "change", ".auto_populate_entity",->
	#   alert "ok"
	#   total_tax = 0
	#   uid = $(this).data('uid')
	#   total_count = $(this).data('total-count')
	#   counter = $(this).data('counter')
	#   entity_type = $(this).data('entity-type')
	#   entity_value = $(this).val()
	#   percent = $(this).find('option:selected').text().slice(0,-1)
	#   while counter <= total_count-1
	#     if $(".#{entity_type}_serial_#{counter}").is(':enabled')
	#       $(".#{entity_type}_serial_#{counter} option[value=#{entity_value}]").prop('selected',true);
	#       product = $(".#{entity_type}_serial_#{counter} option[value=#{entity_value}]").data("product-id")
			
	#       $(".tax_class_of_#{product}_#{uid}").each (index) ->
	#         if ($(this).is ":checked")
	#           tax_id = $(this).data("tax-id")
	#           tax_value = $(this).data("tax-amount")
	#           tax_type = $(this).data("tax-type")
	#           tax_amount = calculate_tax_amount(product, tax_id, tax_value, tax_type, uid)
	#           total_tax = parseFloat(total_tax)
	#           tax_amount = parseFloat(tax_amount)
	#           total_tax = total_tax + tax_amount
	#       total_tax = parseFloat(total_tax)

	#       lending_price = Number($(".landing-price-#{product}").val())
	#       mrp = lending_price + total_tax + Number((lending_price*percent)/100)
	#       sale_price = lending_price + total_tax + Number((lending_price*percent)/100)
	#       $(".mrp-#{product}").val(mrp)
	#       $(".sale-price-#{product}").val(sale_price)
	#     counter++
	#   return  

	# $(document).on "change keyup", ".auto_populate_entity",->
	#   total_count = $(this).data('total-count')
	#   counter = $(this).data('counter')
	#   entity_type = $(this).data('entity-type')
	#   entity_value = $(this).val()
	#   product_id = $(this).data('product-id')
	#   # uid = $(this).data('uid')
	#   # while counter <= total_count-1
	#   while counter <= total_count
	#     total_tax = 0
	#     uid = $(".#{entity_type}_serial_#{counter}").data("uid")
	#     #$(".hidden_sales_percentage_#{product_id}_#{uid}").val($(this).val())
	#     # percent = $(".hidden_sales_percentage_#{product_id}_#{uid}").val()
	#     percent = $(this).val()
	#     product = $(".#{entity_type}_serial_#{counter}").data("product-id")
	#     $(".hidden_sales_percentage_#{product}_#{uid}").val($(this).val())
	#     if $(".#{entity_type}_serial_#{counter}").is(':enabled')
	#       $(".#{entity_type}_serial_#{counter}").val(percent)
	#       $(".tax_class_of_#{product}_#{uid}").each (index) ->
	#         if ($(this).is ":checked")
	#           tax_id = $(this).data("tax-id")
	#           tax_value = $(this).data("tax-amount")
	#           tax_type = $(this).data("tax-type")
	#           tax_amount = calculate_tax_amount(product, tax_id, tax_value, tax_type, uid)
	#           total_tax = parseFloat(total_tax)
	#           tax_amount = parseFloat(tax_amount)
	#           total_tax = total_tax + tax_amount
	#       total_tax = parseFloat(total_tax)

	#       lending_price = Number($(".landing-price-#{product}-#{uid}").val())
	#       mrp = lending_price + total_tax
	#       mrp = mrp + Number((mrp*percent)/100)
	#       sale_price = lending_price + total_tax
	#       sale_price = sale_price + Number((lending_price*percent)/100)
	#       if total_tax > 0
	#         sale_price = (Math.round(sale_price / 10) * 10)
	#         mrp = (Math.round(mrp / 10) * 10)
	#       $(".mrp-#{product}-#{uid}").val(mrp)
	#       $(".sale-price-#{product}-#{uid}").val(sale_price)
	#     counter++
	#   return

	$(document).on "keyup", ".auto_populate_entity",->
		total_count = $(this).data('total-count')
		counter = $(this).data('counter')
		entity_type = $(this).data('entity-type')
		entity_value = $(this).val()
		product_id = $(this).data('product-id')
		uid = $(this).data('uid')
		total_tax = 0
		$(".hidden_sales_percentage_#{product_id}_#{uid}").val($(this).val())
		percent = $(".hidden_sales_percentage_#{product_id}_#{uid}").val()
		if $(".#{entity_type}_serial_#{counter}").is(':enabled')
			$(".#{entity_type}_serial_#{counter}").val(percent)
			$(".tax_class_of_#{product_id}_#{uid}").each (index) ->
				if ($(this).is ":checked")
					tax_id = $(this).data("tax-id")
					tax_value = $(this).data("tax-amount")
					tax_type = $(this).data("tax-type")
					tax_amount = calculate_tax_amount(product_id, tax_id, tax_value, tax_type, uid)
					total_tax = parseFloat(total_tax)
					tax_amount = parseFloat(tax_amount)
					total_tax = total_tax + tax_amount
			total_tax = parseFloat(total_tax)

			lending_price = Number($(".landing-price-#{product_id}-#{uid}").val())
			mrp = lending_price + total_tax
			mrp = mrp + Number((mrp*percent)/100)
			sale_price = lending_price + total_tax
			sale_price = sale_price + Number((lending_price*percent)/100)
			if total_tax > 0
				sale_price = (Math.round(sale_price / 10) * 10)
				mrp = (Math.round(mrp / 10) * 10)
			$(".mrp-#{product_id}-#{uid}").val(mrp)
			$(".sale-price-#{product_id}-#{uid}").val(sale_price)
		return

	$(document).on "change", ".tax_class_list", ->
		product_id = $(this).data("product-id")
		tax_input = $(this).val()
		uid = $(this).data("uid")
		tax_input = tax_input.split("__")
		$(".tax-line-#{product_id}-#{tax_input[0]}-#{uid}").remove() if $(".tax-line-#{product_id}-#{tax_input[0]}-#{uid}").length
		if tax_input[0] > 0
			tax_amount = calculate_product_tax_amount(product_id, tax_input[0], tax_input[1], tax_input[3],uid)
			$(".tax-line-#{product_id}-#{tax_input[0]}-#{uid}").remove() if $(".tax-line-#{product_id}-#{tax_input[0]}-#{uid}").length
			tax_str = "
				<div class='row margin-l-r-none tax-line-#{product_id}-#{tax_input[0]}-#{uid}'><div class='col-lg-5 padding-l-r-none'>
				<input class='tax_class purchase_input filled-in tax_class_of_#{product_id} tax_class_of_#{product_id}_#{uid}' data-product-id='#{product_id}' data-tax-id='#{tax_input[0]}' data-tax-amount='#{tax_input[1]}' data-tax-type='#{tax_input[3]}' data-uid='#{uid}' id='tax_class_#{tax_input[0]}_#{product_id}_#{uid}' name='tax_class_#{product_id}[]' type='checkbox' value='#{tax_input[0]}' checked>
				<label class='font-sz-11 margin-t-5 padding-l-20' for='tax_class_#{tax_input[0]}_#{product_id}_#{uid}'>#{tax_input[2]} @#{tax_input[1]}</label>
				</div>
				<div class='col-lg-4 padding-l-r-none'><select name='tax-on-#{product_id}-#{tax_input[0]}' class='form-control purchase_input tax-on-#{product_id}-#{tax_input[0]}' data-product-id='#{product_id}' data-uid='#{uid}'><option value=''>Tax aplicable on</option><option value='Landing_Price' selected>Landing Price</option><option value='MRP'>MRP</option><select></div>
				<div class='col-lg-3 padding-l-r-none'>
				<input value='#{tax_amount}' class='margin-b-2 validate allow-numeric-only form-control purchase_input tax-inputs tax_class_input_#{tax_input[0]}_#{product_id} tax_class_input_#{tax_input[0]}_#{product_id}_#{uid}' data-product-id='#{product_id}' data-tax-id='#{tax_input[0]}' id='tax_class_#{tax_input[0]}_#{product_id}' name='tax_class_#{tax_input[0]}_#{product_id}' placeholder='Total Amount' type='text' style='display: block;' required=''>
				</div></div>"
			$("#tax-input-container-#{product_id}-#{uid}").prepend(tax_str)
		calculate_price_wt product_id, uid

		return

	# to calculate additional cost
	$(document).on "keyup",".purchase_input_additional_cost", ->
		additional_cost = parseFloat($(this).val())
		additional_cost = 0 if isNaN(additional_cost)
		product_id = $(this).data("product-id")
		console.log(product_id)
		total_price = parseFloat($(".product_price_wt_#{product_id}_1").val())
		total_price = 0 if isNaN(total_price)
		total_price = total_price+additional_cost
		$(".product_price_wt_#{product_id}_1").val(total_price)
		return 
	
	# Calculate price without tax 
	calculate_price_wot = (product_id,uid) ->
		#pqty = parseFloat($(".quantity-#{product_id}-#{uid}").val())  
		#pqty = 0 if isNaN(pqty)
		inputQty = parseFloat($(".input_quantity_of_#{product_id}").val())
		inputQty = 0 if isNaN(inputQty)
		lprice = parseFloat($(".landing-price-#{product_id}-#{uid}").val())
		lprice = 0 if isNaN(lprice)
		discount = parseFloat($(".discount-amount-#{product_id}-#{uid}").val())    
		discount = 0 if isNaN(discount)   
		pwot = ((inputQty * lprice) - discount)
		$(".price-wot-#{product_id}-#{uid}").val(pwot)
		return
	# Calculate price with tax  
	calculate_price_wt = (product_id,uid) ->
		total_tax = 0
		pro_total_tax = 0
		price_wot = parseFloat($(".price-wot-#{product_id}-#{uid}").val())
		additional = parseFloat($(".pro-additional-cost-#{product_id}-#{uid}").val())
		additional = 0 if isNaN(additional)
		percent = $(".hidden_sales_percentage_#{product_id}_#{uid}").val()
		additional = 0 if isNaN(percent)
		$(".tax_class_of_#{product_id}_#{uid}").each (index) ->
			if ($(this).is ":checked")
				tax_id = $(this).data("tax-id")
				tax_value = $(this).data("tax-amount")
				tax_type = $(this).data("tax-type")
				tax_amount = calculate_product_tax_amount(product_id, tax_id, tax_value, tax_type, uid)
				$(".tax_class_input_#{tax_id}_#{product_id}_#{uid}").val(tax_amount)
				total_tax = parseFloat(total_tax)
				tax_amount = parseFloat(tax_amount)
				total_tax = total_tax + tax_amount

				pro_tax_amount = calculate_tax_amount(product_id, tax_id, tax_value, tax_type, uid)
				pro_total_tax = parseFloat(pro_total_tax)
				pro_tax_amount = parseFloat(pro_tax_amount)
				pro_total_tax = pro_total_tax + pro_tax_amount

		lending_price = Number($(".landing-price-#{product_id}-#{uid}").val())
		mrp = lending_price + pro_total_tax
		mrp = mrp + Number((mrp*percent)/100)
		if pro_total_tax > 0
			mrp = (Math.round(mrp / 10) * 10)

		sale_price = lending_price + pro_total_tax
		land_tax = sale_price
		sale_price = sale_price + Number((sale_price*percent)/100)
		if pro_total_tax > 0
			sale_price = (Math.round(sale_price / 10) * 10)
		profit = (100 * (sale_price - land_tax) / land_tax).toFixed(2)

		if typeof(percent) != 'undefined'
			$(".mrp-#{product_id}-#{uid}").val(mrp)
			$(".sale-price-#{product_id}-#{uid}").val(sale_price)
		if pro_total_tax > 0 && profit > 0
			$(".sales_percentage_#{product_id}_#{uid}").val(profit)
		total_tax = parseFloat(total_tax)
		price_wt = (price_wot + total_tax + additional)
		$(".product_price_wt_#{product_id}_#{uid}").val(price_wt)
		calculate_po_total()
		return

	calculate_profit = (product_id, uid) ->
		pro_total_tax = 0
		percent = $(".hidden_sales_percentage_#{product_id}_#{uid}").val()
		$(".tax_class_of_#{product_id}_#{uid}").each (index) ->
			if ($(this).is ":checked")
				tax_id = $(this).data("tax-id")
				tax_value = $(this).data("tax-amount")
				tax_type = $(this).data("tax-type")

				pro_tax_amount = calculate_tax_amount(product_id, tax_id, tax_value, tax_type, uid)
				pro_total_tax = parseFloat(pro_total_tax)
				pro_tax_amount = parseFloat(pro_tax_amount)
				pro_total_tax = pro_total_tax + pro_tax_amount

		lending_price = Number($(".landing-price-#{product_id}-#{uid}").val())
		sale_price = Number($(".sale-price-#{product_id}-#{uid}").val()) + pro_total_tax
		land_tax = lending_price + pro_total_tax
		sale_price = sale_price + Number((sale_price*percent)/100)
		if pro_total_tax > 0
			sale_price = (Math.round(sale_price / 10) * 10)
		diff = sale_price - land_tax
		profit = (100 * (sale_price - land_tax) / land_tax).toFixed(2)
		if pro_total_tax > 0 && profit > 0
			$(".sales_percentage_#{product_id}_#{uid}").val(profit)




	calculate_product_tax_amount = (product_id, tax_id, tax_value, tax_type, uid) ->

		mrp_price = parseFloat($(".mrp-#{product_id}-#{uid}").val())
		land_price = parseFloat($(".landing-price-#{product_id}-#{uid}").val())   
		tax_on = $(".tax-on-#{product_id}-#{tax_id}").val()
		pqty = parseFloat($(".input_quantity_of_#{product_id}").val())
		console.log(land_price,tax_on,pqty)
		tax_amount = 0
		tax_amount = parseFloat(tax_value) if tax_type is "fixed_amount"
		if tax_on is "MRP"
			tax_amount = ((mrp_price * parseFloat(tax_value) / 100)*pqty) if tax_type is "percentage"
		else if tax_on is "Landing_Price"
			tax_amount = ((land_price * parseFloat(tax_value) / 100)*pqty) if tax_type is "percentage"  
		return (tax_amount)

	calculate_tax_amount = (product_id, tax_id, tax_value, tax_type, uid) ->
		mrp_price = parseFloat($(".mrp-#{product_id}-#{uid}").val())
		land_price = parseFloat($(".landing-price-#{product_id}-#{uid}").val())   
		tax_on = $(".tax-on-#{product_id}-#{tax_id}").val()

		tax_amount = 0
		tax_amount = parseFloat(tax_value) if tax_type is "fixed_amount"
		if tax_on is "MRP"
			tax_amount = (mrp_price * parseFloat(tax_value) / 100) if tax_type is "percentage"
		else if tax_on is "Landing_Price"
			tax_amount = (land_price * parseFloat(tax_value) / 100) if tax_type is "percentage"  
		return (tax_amount)  

	calculate_po_total = ->
		#po_total = parseFloat($(".po_total_input").val())
		#$(".product-total-wt").each (index) ->
		#  total_amount = parseFloat($(this).val())
		#  po_total += total_amount
		#  po_total = Math.round(po_total)
		#$(".po_total_amount").html(po_total)
		#countter = 1
		

		total_po_cost = parseFloat(0)
		$(".check_purchase_input").each (index)-> 
			if ($(this).prop("checked")==true)
				u_id = $(this).data("uid")
				product_id = $(this).data("product-id")
				total_po_cost += parseFloat($(".product_price_wt_#{product_id}_#{u_id}").val())
		total_po_cost = Math.round(total_po_cost)
		$(".po_total_amount").html(total_po_cost)
		return

	# calculating purchase cost by margin on mrp
	calculate_purchase_price = (product_id,uid) ->
		margin_on_mrp = parseFloat($(".margin_on_mrp_#{product_id}_#{uid}").val())
		margin_on_mrp = 0 if isNaN(margin_on_mrp)
		mrp = parseFloat($(".mrp-#{product_id}-#{uid}").val())
		mrp = 0 if isNaN(mrp)
		purchase_cost = mrp*100/(100+margin_on_mrp)
		$(".purchase_cost_#{product_id}_#{uid}").val(purchase_cost)
		return

	# calculating landing price
	calculate_landing_price = (product_id,uid) ->
		volume_discount = parseFloat($(".volume_discount_#{product_id}_#{uid}").val())
		volume_discount = 0 if isNaN(volume_discount)
		scheme_discount = parseFloat($(".scheme_discount_#{product_id}_#{uid}").val())
		scheme_discount = 0 if isNaN(scheme_discount)
		scheme_discount_by_amount = parseFloat($(".scheme_discount_by_amount_#{product_id}_#{uid}").val())
		scheme_discount_by_amount = 0 if isNaN(scheme_discount_by_amount)

		purchase_cost = parseFloat($(".purchase_cost_#{product_id}_#{uid}").val())
		purchase_cost = 0 if isNaN(purchase_cost)
		quantity = parseFloat($(".quantity-#{product_id}-#{uid}").val())
		quantity = 0 if isNaN(quantity)
		travelling_cost = parseFloat($("#travelling_cost").val()) 
		travelling_cost = 0 if isNaN(travelling_cost)
		total_discount_on_po = parseFloat($("#discount_on_po").val())
		total_discount_on_po = 0 if isNaN(total_discount_on_po)

		quantity_wof = parseFloat($(".input_quantity_#{product_id}_#{uid}").val())
		quantity_wof = 0 if isNaN(quantity_wof)
		
		a = parseFloat(purchase_cost * quantity_wof)
		b = parseFloat(a * (100 - volume_discount) / 100)
		c = parseFloat(b * (100 - scheme_discount) / 100)
		d = parseFloat(c - scheme_discount_by_amount)
		e = parseFloat(d / quantity)

		total_qty = 0
		$('.stock_purchase_received:checkbox:checked').map ->
			p_id = $(this).data('product-id')
			u = $(this).data('uid')
			qty = parseFloat($(".quantity-#{p_id}-#{u}").val())
			qty = 0 if isNaN(qty)
			total_qty = total_qty + qty
		
		landing_price = e + (travelling_cost/total_qty) - (total_discount_on_po/total_qty)
		landing_price = 0 if isNaN(landing_price)

		$(".landing-price-#{product_id}-#{uid}").val(landing_price)

		sale_price = parseFloat($(".sale-price-#{product_id}-#{uid}").val())
		mrp = parseFloat($(".mrp-#{product_id}-#{uid}").val())
		sale_price = 0 if isNaN(sale_price)
		mrp = 0 if isNaN(mrp)

		if landing_price > sale_price
			Materialize.toast("Landing price should be less than Sale price.", 3000,'red')
			#$(".landing-price-#{product_id}-#{uid}").addClass('red')
		else
			#$(".landing-price-#{product_id}-#{uid}").removeClass('red')
		if landing_price > mrp
			Materialize.toast("Landing price should be less than Mrp.", 3000,'red')
			#$(".landing-price-#{product_id}-#{uid}").css('color', 'red')
		else
			#$(".landing-price-#{product_id}-#{uid}").css('color', '')

		return

	# calculating selling price
	calculate_selling_price = (product_id,uid) ->
		mrp = parseFloat($(".mrp-#{product_id}-#{uid}").val())
		mrp = 0 if isNaN(mrp)
		discount_on_mrp = parseFloat($(".discount_on_mrp_#{product_id}_#{uid}").val())
		discount_on_mrp = 0 if isNaN(discount_on_mrp)

		# if discount_on_mrp == 0
		#   selling_price = parseFloat($(".purchase_cost_#{product_id}_#{uid}").val())
		# else
		selling_price = mrp * (100-discount_on_mrp) / 100

		$(".sale-price-#{product_id}-#{uid}").val(selling_price)

		landing_price = parseFloat($(".landing-price-#{product_id}-#{uid}").val())
		if landing_price > selling_price
			Materialize.toast("Sale price should be greater than Landing price.", 3000,'red')
			#$(".sale-price-#{product_id}-#{uid}").addClass('red')
		else
			#$(".sale-price-#{product_id}-#{uid}").removeClass('red')
		if selling_price > mrp
			Materialize.toast("Sale price should be less than Mrp.", 3000,'red')
			#$(".sale-price-#{product_id}-#{uid}").css('color', 'red')
		else
			#$(".sale-price-#{product_id}-#{uid}").css('color','')

		return

	# calculating all landing price
	calculate_all_landing_price = ->
		total_qty = parseFloat(0)
		po_total = parseFloat(0)
		$('.stock_purchase_received:checkbox:checked').map ->
			product_id = $(this).data('product-id')
			uid = $(this).data('uid')
			qty = parseFloat($(".quantity-#{product_id}-#{uid}").val())
			qty = 0 if isNaN(qty)
			total_qty = total_qty + qty

		$('.stock_purchase_received:checkbox:checked').map ->
			product_id = $(this).data('product-id')
			uid = $(this).data('uid')
			volume_discount = parseFloat($(".volume_discount_#{product_id}_#{uid}").val())
			volume_discount = 0 if isNaN(volume_discount)
			scheme_discount = parseFloat($(".scheme_discount_#{product_id}_#{uid}").val())
			scheme_discount = 0 if isNaN(scheme_discount)
			scheme_discount_by_amount = parseFloat($(".scheme_discount_by_amount_#{product_id}_#{uid}").val())
			scheme_discount_by_amount = 0 if isNaN(scheme_discount_by_amount)

			purchase_cost = parseFloat($(".purchase_cost_#{product_id}_#{uid}").val())
			purchase_cost = 0 if isNaN(purchase_cost)
			quantity = parseFloat($(".quantity-#{product_id}-#{uid}").val())
			quantity = 0 if isNaN(quantity)
			travelling_cost = parseFloat($("#travelling_cost").val()) 
			travelling_cost = 0 if isNaN(travelling_cost)
			total_discount_on_po = parseFloat($("#discount_on_po").val())
			total_discount_on_po = 0 if isNaN(total_discount_on_po)

			quantity_wof = parseFloat($(".input_quantity_#{product_id}_#{uid}").val())
			quantity_wof = 0 if isNaN(quantity_wof)

			a = parseFloat(purchase_cost * quantity_wof)
			b = parseFloat(a * (100 - volume_discount) / 100)
			c = parseFloat(b * (100 - scheme_discount) / 100)
			d = parseFloat(c - scheme_discount_by_amount)
			e = parseFloat(d / quantity)
			
			landing_price = e + (travelling_cost/total_qty) - (total_discount_on_po/total_qty)
			landing_price = 0 if isNaN(landing_price)

			$(".landing-price-#{product_id}-#{uid}").val(landing_price)

			total_price_wt = landing_price * quantity
			total_price_wt = 0 if isNaN(total_price_wt)

			$(".product_price_wt_#{product_id}_#{uid}").val(total_price_wt)

			po_total += total_price_wt
			po_total = Math.round(po_total)
			po_total = 0 if isNaN(po_total)

		$(".po_total_amount").html(po_total)

		return

	$(document).on "keyup", ".smart_purchase_cost",->
		product_id = $(this).data('product-id')
		uid = $(this).data('uid')
		mrp = parseFloat($(".mrp-#{product_id}-#{uid}").val())
		mrp = 0 if isNaN(mrp)
		purchase_cost = $(this).val()
		purchase_cost = 0 if isNaN(purchase_cost)
		# purchase_cost = mrp*100/(100+margin_on_mrp)
		margin_on_mrp = (( mrp * 100 ) / purchase_cost) - 100
		$(".margin_on_mrp_#{product_id}_#{uid}").val(margin_on_mrp)
		return

	# adding free quantity  
	$(document).on "click keyup", ".adding_free_qty",->
		pom_id = $(this).data("pom-id")
		uid = $(this).data("uid")
		product_id = $(this).data('product-id')
		qty = parseFloat($(".input_quantity_of_#{pom_id}_#{uid}").val())
		qty = 0 if isNaN(qty)
		free_qty = parseFloat($(".free_quantity_#{pom_id}_#{uid}").val())
		free_qty = 0 if isNaN(free_qty)
		total_qty = qty + free_qty
		$(".quantity-#{product_id}-#{uid}").val(total_qty)
		return

	$(document).on "keypress", "#product_search", (event)-> 
		if event.keyCode == 13
			$('#product_add_btn').click()
			return

	$(document).on "click", "#product_add_btn", (event)-> 
		event.preventDefault()
		product_name = $('#product_search').val()
		po_id = $("#po_id").val()
		# po_ids = []
		u_ids = []

		# $(".stock_purchase_received").each ->
		#   po_ids.push parseInt($(this).data('po-id'))

		# max_pom_id = Math.max.apply(Math,po_ids)
		request_pom = $.ajax(
			type: 'POST'
			url: "/purchase_orders/save_pom"
			data:
				product_name: product_name
				purchase_order_id: po_id
		)
		request_pom.done (data_pom, textStatus_pom, jqXHR_pom) ->
			data_pom = data_pom.all_data.data
			$(".stock_purchase_received").each ->
				u = parseInt($(this).data('uid'))
				u = 0 if isNaN(u)
				u_ids.push u
			max_uid = Math.max.apply(Math,u_ids)
			request = $.ajax(
				type: 'GET'
				url: "/api/v2/stock_purchases/generate_stock_receive_row"
				data:
					product_name: product_name
					# pom_id: max_pom_id + 1
					pom_id: data_pom.id
				dataType: "json"
			)
			request.done (data, textStatus, jqXHR) ->
				console.log data
				data.product = data.data.product
				data.product_sku = data.data.product_sku
				data.configurations = data.data.configurations
				data.pom_id = data.data.pom_id
				data.sales_percentages = data.data.sales_percentages
				data.max_u = max_uid
				data.product_unit_name = data.data.product_unit_name
				result = JST["templates/stock_purchases/add_receive_row"](data)
				$(".test").prepend result
				return
			request.error (jqXHR, textStatus, errorThrown) ->
				console.log textStatus
				Materialize.toast("Product #{product_name} does not exist.", 5000)
				return
		request_pom.error (jqXHR_pom, textStatus_pom, errorThrown_pom) ->
			console.log textStatus_pom
			Materialize.toast("Something went wrong.", 5000)
			return

	$(document).on "click","#print_po_recieve",(event) ->
		stock_purchase_id = $(this).data("stock-purchase-id")
		request_path = $(this).data("request-path")
		request = $.ajax(
			type: 'GET'
			url: request_path
			dataType: "json"
			)
		request.done (data, textStatus, jqXHR) ->
			console.log(data)
			data.response = data
			#po_result = JST["templates/purchase_orders/po_receive_invoice"](data)
			#$("#poDetails").html(po_result)
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			Materialize.toast("Something went wrong in request", 5000)
			return
		$("poReceivePrintmodal").modal()
		return

	$(document).on "click",".print_po_receive_details",(event) ->
		htmlToPrint =""
		divToPrint = document.getElementById('poDetails')
		htmlToPrint += divToPrint.innerHTML
		newWin = window.open('')
		newWin.document.write htmlToPrint
		newWin.print()
		newWin.close()
		return

	# compare_sale_landing_mrp = (sale_price, landing_price, mrp, product_id, uid) ->

	#   # mrp > sale price > landing price

	#   if landing_price > sale_price
	#     Materialize.toast("Sale price should be greater than Landing price.", 3000,'red')
	#     $(".sale-price-#{product_id}-#{uid}").addClass('red')
	#   else
	#     $(".sale-price-#{product_id}-#{uid}").removeClass('red')

	#   if sale_price > mrp
	#     Materialize.toast("Sale price should be less than Mrp.", 3000,'red')
	#     $(".sale-price-#{product_id}-#{uid}").css('color', 'red')
	#   else
	#     $(".sale-price-#{product_id}-#{uid}").css('color','')

	#   if landing_price > mrp
	#     Materialize.toast("Landing price should be less than Mrp.", 3000,'red')
	#     $(".landing-price-#{product_id}-#{uid}").css('color', 'red')
	#   else
	#     $(".landing-price-#{product_id}-#{uid}").css('color', '')    

	#   return 


########### Wirehouse module js starts in stock purchase ##############################

	$(document).on "click", ".grid-wrapper", ->
		$.ajax "/warehouse_meta/racks",
			method: 'GET',
			data: {id:$(this).data("rack-id")},
			dataType:"json",
			success: (data,textStatus,jqXHR)->
				htmlStr = "<div class='grid-wrapper' style='width: 250px !important;grid-gap:9px !important;'>"
				for i in[0..data.data.length-1]
					if data.data[i]["status"] == "available"
						htmlStr+= "<div class='grid-box-available product_rack "+data.data[i].bin_unique_id+"' data-row-unique-id="+data.data[i].bin_unique_id+" style='width: 230px !important; height:50px !important'>#{data.data[i]['bin_unique_id']}</div>"
					if data.data[i]["status"] == "allocated"
						htmlStr+= "<div class='grid-box-allocated isDraggable product_rack "+data.data[i].bin_unique_id+"' data-row-unique-id="+data.data[i].bin_unique_id+" style='width: 230px !important;height:50px !important'>"+$("#bin#{data.data[i]['bin_unique_id']}").html()+"</div>"
					if data.data[i]["status"] == "damaged"
						htmlStr+= "<div class='grid-box-damaged product_rack "+data.data[i].bin_unique_id+"' data-row-unique-id="+data.data[i].bin_unique_id+" style='width: 230px !important;height:50px !important'>#{data.data[i]['bin_unique_id']}</div>"
				htmlStr+="</div>"
				$("#ModalRack").html(htmlStr) 
				$('.isDraggable').draggable
					helper : 'clone'
				$('.product_rack').droppable
					drop: (event, ui) ->
						product_sku = $(ui.draggable).data("sku")
						bin_unique_id = $(this).data("row-unique-id")
						add_product = $.ajax(
							type: 'POST'
							url: "/api/v2/warehouses/put_product?email="+$("#current_user_email").data("current-user-email")+"&device_id=YOTTO05"
							data:
								bin_products:
									bin_unique_id: bin_unique_id
									sku: product_sku
									product_quantity: 10  
						)
						add_product.done (data,textStatus,jqXHR) ->
							if data.status != "error"
								Materialize.toast("Product succesfuly put into bin.", 5000,'green')
								$(".#{bin_unique_id}").removeClass("grid-box-available").addClass("grid-box-allocated isDraggable")
								$(".#{bin_unique_id}").html("<div class='col-sm-8'>#{data.data.product_name}</div>")
								$(".#{bin_unique_id}").append("<div class='col-sm-2'><span class='badge' style='margin-top:5px;margin-left:65%;'>#{data.data.product_quantity}</span></div>")
								$("#bin#{bin_unique_id}").html("<div class='col-sm-8'>#{data.data.product_name}</div>")
								$("#bin#{bin_unique_id}").append("<div class='col-sm-2'><span class='badge' style='margin-top:5px;margin-left:65%;'>#{data.data.product_quantity}</span></div>")
								$('.isDraggable').draggable
									helper : 'clone'
								$('.isDraggable').draggable('enable')
								result = product_quantity_status  product_sku
								$("#product_allocations_#{product_sku}").text("#{result['allocation']}/#{result['stock_credit']}")
								if(result['allocation'] == result['stock_credit'])
										$("#allocation_satatus_#{product_sku}").html("<i class='fa fa-check-circle fa-2x' style='color:#fff';></i>")
							else
								 Materialize.toast(data.messages.internal_message, 5000,'red')
							return
						add_product.error (jqXHR,textStatus,errorThrown) ->
							alert("Something went wrong,no responce from server")
							return                  
						return
					over:(event,ui) ->
						return
				return
			error: (jqXHR, textStatus, errorThrown) ->
				alert("ajax error")
				return
		return

	#####make the product-box draggable
	$('.product-box').draggable
		helper: 'clone'
	
	### make the product container div (.product-wrapper) dropable so that we can put product back to the container from the bin #######
	
	$('.product-wrapper').droppable
		drop : (event,ui) ->
			if ($(ui.draggable).hasClass('isDraggable'))
				console.log('bin id = '+ $(ui.draggable).data('row-unique-id'))
				$.ajax
					type  : "post"
					async :false
					url   : "/api/v2/warehouses/pick_product?email="+$("#current_user_email").data("current-user-email")+"&device_id=YOTTO05"
					data  :
						bin_unique_id    : $(ui.draggable).data('row-unique-id')
						product_quantity : 10
					success : (responseData,textStatus,jqXHR) ->
						if responseData.status == 'ok'
							$(ui.draggable).removeClass("grid-box-allocated isDraggable").addClass("grid-box-available").html('')
							$(ui.draggable).text($(ui.draggable).data('row-unique-id'))
							$(ui.draggable).draggable('disable')
							$("#bin#{$(ui.draggable).data('row-unique-id')}").html('')
							$("#bin#{$(ui.draggable).data('row-unique-id')}").addClass('grid-box-available').text("#{$(ui.draggable).data('row-unique-id')}")
							Materialize.toast("Product succesfuly removed from bin.", 5000,'green')
							update_quantity_status()
						else
							Materialize.toast(responseData.messages.internal_message, 5000,'red')
						return
					error   :(responseData, textStatus, errorThrown) ->
						Materialize.toast('ajax responce error', 5000,'red')
						return
			return
	$(document).on "click","#add_to_rack", ->
		update_quantity_status()
		return

	update_quantity_status = ->
		$(".product-box").each (index) ->
			result = product_quantity_status ($(this).data("sku"))
			console.log(result)
			$(this).children('.product_info').children('.product_allocations').text("#{result['allocation']}/#{result['stock_credit']}")
			if (result['allocation'] == result['stock_credit'])
				$(this).children('.product_info').children('.allocation_satatus').html("<i class='fa fa-check-circle fa-2x' style='color:#fff';></i>")
			else
				$(this).children('.product_info').children('.allocation_satatus').html("")
		return
####### call this function to get the credited stocks and allocation quantity in a bin for a SKU  ########## 
	product_quantity_status=(sku)->
		product_stock_and_quantity = {}
		quantity_in_bin = 0
		$.ajax
			type: "get"
			async :false
			url : "/api/v2/warehouses/product_bins?email="+$("#current_user_email").data("current-user-email")+"&device_id=YOTTO05"
			data: 
				sku : sku
			success :(responseData, textStatus, jqXHR) ->
				product_stock_and_quantity["stock_credit"] = responseData.data.stock_credit
				for present_in_bin in responseData.data.bins
					quantity_in_bin += present_in_bin.product_quantity
				product_stock_and_quantity["allocation"] = quantity_in_bin
				return 
			error :(responseData, textStatus, errorThrown) ->
				console.log("error")
				return "error"
		return product_stock_and_quantity 
######### Wirehouse module js end  in stock purchase ########################

	
	$(document).on "click","#cancel-stock-purchase-btn", ->
		stock_purchase_id = $(this).data('stock-purchase-id')
		store_id = $(this).data('store-id')
		return false if !window.confirm('Are you sure to cancel the full purchase?')
		request = $.ajax(
			type: 'POST'
			url: "/stock_purchases/cancel_stock_purchase"
			data:
				stock_purchase_id: stock_purchase_id
				store_id: store_id
		)
		request.done (data, textStatus, jqXHR) ->
			console.log data
			Materialize.toast("Stock Purchase Id: #{stock_purchase_id} cancelled successfully.", 5000, "green")
			window.location.href = "/stores/#{store_id}"
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			console.log textStatus
			Materialize.toast("Something went wrong.", 5000, "red")
			location.reload(true)
			return

	$(document).on "click",".cancel_item_in_sp", ->
		cancel_btn = $(this)
		stock_purchase_id = $(this).data('stock-purchase-id')
		store_id = $(this).data('store-id')
		uid = $(this).data('uid')
		pom_id = $(this).data('pom-id')
		product_id = $(this).data('product-id')
		stock_cancel_qty = $(".cancel_stock_#{pom_id}_#{uid}").val()
		product_name = $(this).data('product-name')
		return false if !window.confirm("Are you sure to cancel #{product_name}?")
		request = $.ajax(
			type: 'POST'
			url: "/stock_purchases/cancel_stock_purchase"
			data:
				stock_purchase_id: stock_purchase_id
				store_id: store_id
				product_id: product_id
				"stock_cancel_qty_#{product_id}": stock_cancel_qty
		)
		request.done (data, textStatus, jqXHR) ->
			console.log data
			Materialize.toast("Product #{product_name} cancelled successfully.", 5000, "green")
			cancel_btn.css("pointer-events","none")
			cancel_btn.removeClass('red')
			cancel_btn.css('background', '#aaa')
			return
		request.error (jqXHR, textStatus, errorThrown) ->
			console.log textStatus
			Materialize.toast("Something went wrong.", 5000, "red")
			return

	$(document).on "keyup",".cancel_stock_qty", ->
		cancel_qty = parseFloat($(this).val())
		uid = $(this).data('uid')
		pom_id = $(this).data('pom-id')
		available_stock = parseFloat($("#available_stock_qty_#{pom_id}_#{uid}").val())
		if cancel_qty > available_stock
			Materialize.toast("More than available stock can not be cancelled.", 5000, "red")
			$(this).val available_stock
		return   

	$(document).on "click",".printdetails", ->
		alert "Implementation in progress........."
		return   
