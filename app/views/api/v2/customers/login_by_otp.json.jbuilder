json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_customer_login)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_customer_login)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data do
    json.otp_id @phone_number.id
    json.otp @phone_number.otp
    json.customer do
    	json.extract! @customer_login, :id,:mobile_no, :email, :created_at, :updated_at
    end
  end
end