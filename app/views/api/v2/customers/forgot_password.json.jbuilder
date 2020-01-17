json.status (@error.present? or @customer.blank?) ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_customer_found)
  json.simple_message @customer.blank? ? I18n.t(:error_no_records_found) : I18n.t(:success_customer_found)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_customer_found)
  json.internal_message @customer.blank? ? I18n.t(:error_no_records_found) : I18n.t(:success_customer_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present? or @customer.blank?
  json.data Hash.new
else
  json.data do    
    json.extract! @phone_number, :id, :phone_number, :otp
  end
end