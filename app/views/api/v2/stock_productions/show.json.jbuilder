json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_stock_production_not_found) : I18n.t(:success_stock_production_found)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_stock_production_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
  json.data Array.new
else
	json.data do
		json.partial! 'api/v2/stock_productions/stock_production_details', stock_production: @stock_production
  end
end