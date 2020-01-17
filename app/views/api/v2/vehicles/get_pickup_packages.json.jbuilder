json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_success_shipment) : I18n.t(:success_shipment)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_shipment)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Array.new
else
  json.data @packages, partial: 'api/v2/vehicles/stock_transfer', as: :object
end




 