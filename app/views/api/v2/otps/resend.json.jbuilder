json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_otp_not_sent) : I18n.t(:success_otp_resend)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_otp_resend)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data do
    json.extract! @phone_number, :id, :phone_number, :otp
  end  
end