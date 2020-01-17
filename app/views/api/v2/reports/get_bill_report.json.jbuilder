json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_generating_report) : I18n.t(:success_generating_report, from_date: params[:from_date], to_date: params[:to_date])
  json.internal_message @error.present? ? @error.message : I18n.t(:success_generating_report, from_date: params[:from_date], to_date: params[:to_date])
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
	json.data Array.new
else
	json.data do
		json.count @bills_count
		json.total_billed_amount @total_sale[0].total_bill_amount.to_f.round(2)
		json.total_grand_total @total_sale[0].total_grand_total.to_f.round(2)
		json.total_boh_amount @boh_amount[0].total_boh_amount.to_f.round(2)
		json.total_tax @total_sale[0].total_tax.to_f.round(2)
		json.total_discount @total_sale[0].total_discount.to_f.round(2)
		json.total_settled_amount @settlement_data[:total_settlement].to_f.round(2)
		json.total_card_sale @settlement_data[:card_sale].to_f.round(2)
		json.total_cash_sale @settlement_data[:cash_sale].to_f.round(2)
		json.total_coupon_sale @settlement_data[:coupon_sale].to_f.round(2)
		json.total_wallet_sale @settlement_data[:wallet_sale].to_f.round(2)
		json.loyalty_card_sale @settlement_data[:loyalty_card_sale].to_f.round(2)
		json.third_party_sale @settlement_data[:third_party_sale].to_f.round(2)
		json.other_sale (@settlement_data[:third_party_sale].to_f + @settlement_data[:wallet_sale].to_f + @settlement_data[:loyalty_card_sale].to_f + @settlement_data[:coupon_sale].to_f.round(2)).round(2)
		json.table_sale @table_sale[0].table_sale.to_f.round(2)
		json.total_pax @table_sale[0].total_pax.to_i
		json.apc @table_sale[0].table_sale.to_f.round(2) / (@table_sale[0].total_pax.to_i.nonzero? || 1)
		json.unsettled_amount @total_sale[0].total_grand_total.to_f.round(2) - @settlement_data[:total_settlement].to_f.round(2)
		json.cod_sale @cod_sale[0].cod_sale.to_f.round(2)
		json.section_sale @section_sale[0].section_sale.to_f.round(2)
		json.take_away_sale @take_away_sale[0].take_away_sale.to_f.round(2)
		json.nc_sale @nc_sale[0].nc_sale.to_f.round(2)
		json.void_sale @void_sale[0].void_sale.to_f.round(2)
		json.total_return_amount @return_amount[0].total_return_amount.to_f.round(2)
		json.total_cash_return_amount @cash_return[0].total_cash_return_amount.to_f.round(2)
		json.total_wallet_return_amount @wallet_return[0].total_wallet_return_amount.to_f.round(2)
		json.currency currency 
		json.third_party_sale_details @third_party_sale_details do |key,value|
			json.third_party key
			json.sale_value value
		end
		json.coupon_sale_details @coupon_sale_details do |key,value|
			json.coupon key
			json.sale_value value
		end
		json.bills @bills do |bill|
			json.extract! bill, :id, :serial_no, :bill_amount, :tax_amount, :discount, :grand_total, :created_at, :recorded_at
			json.source bill.orders.first.source 
			json.paymentmode bill.payments do |p_t|
				if p_t.paymentmode_type == 'ThirdPartyPayment'
					paymentmode_type = p_t.paymentmode.third_party_payment_option_name
				else
					paymentmode_type = p_t.paymentmode_type 
				end
				json.paymentmode_type paymentmode_type  
			end
		end
	end
end