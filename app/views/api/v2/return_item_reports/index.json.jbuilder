json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_records_found_with_count, count: @return_report.count)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_records_found_with_count, count: @return_report.count)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
	json.data Array.new
else
	json.data do 
		json.count @count
		json.total_bill_amount @return_report.sum("quantity * price")
		json.bill_quantity @return_report.sum("quantity")
		json.total_cash_returned @return_report.cash_return.sum("price * quantity")
		json.total_wallet_amount_return @return_report.wallet_return.sum("price * quantity")

		json.return_bill_details @return_report do |rtn|
			json.bill_serial_no rtn.bill.serial_no
			json.bill_id rtn.bill_id
			json.product_name rtn.product.name
			json.unit_price rtn.price
			json.quantity rtn.quantity
			json.total_price rtn.price.to_f * rtn.quantity.to_f
			json.customer_name rtn.bill.customer.customer_profile.customer_name if rtn.bill.customer.present?
			json.sku rtn.sku 
		end
	end	
end