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
		json.sales_data @sales_data
		json.order_data @orders_data
		json.cog_data @cog_data		
		json.order_by_source @order_source
		json.most_selling_product_by_price @products_by_price
		json.most_selling_product_by_quantity @products_by_qnantity
		json.settlement_data @settlement_data
		json.cash_sell @cash_sell
		json.card_sell @card_sell
	end
end