json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_processing_purchase) : I18n.t(:success_processing_purchase)
  json.internal_message @error.present? ? JSON.parse(@error)["message"] : I18n.t(:success_processing_purchase)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
  json.data Hash.new
else
  json.data JSON.parse(@response)  
end