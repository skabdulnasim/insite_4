json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_records_found_with_count, count: @bills.count)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_records_found_with_count, count: @bills.count)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Array.new
else
	json.data do
		json.count @count
		json.resource_order_histories @resource_orders, partial: 'api/v2/resource_order_histories/resource_order_history', as: :resource_order_history
	end
end