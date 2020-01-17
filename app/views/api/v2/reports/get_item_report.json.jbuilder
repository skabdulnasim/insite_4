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
		json.count @count
		json.total_billed_amount @total_sale[0].total_bill_amount.to_f.round(2)
		json.total_grand_total @total_sale[0].total_grand_total.to_f.round(2)
		json.total_tax @total_sale[0].total_tax.to_f.round(2)
		json.total_discount @total_sale[0].total_discount.to_f.round(2)
		json.total_settlement @settlement_data[:total_settlement].to_f.round(2)
		json.total_card_sale @settlement_data[:card_sale].to_f.round(2)
		json.total_cash_sale @settlement_data[:cash_sale].to_f.round(2)
		json.loyalty_card_sale @settlement_data[:loyalty_card_sale].to_f.round(2)
		json.third_party_sale @settlement_data[:third_party_sale].to_f.round(2)
		json.other_sale (@settlement_data[:third_party_sale].to_f + @settlement_data[:loyalty_card_sale].to_f).round(2)
		json.currency currency 
		json.product_sells @category_sales do |sale|
			json.extract! sale, :menu_product_id, :product_id, :product_name, :quantity, :sku
			json.total_sale sale.total_sale.to_f.round(2)
		end
	end
end