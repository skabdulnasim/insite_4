
if @custom_error.present?
  json.status "error"
  json.error_message @custom_error
else
  json.status (@error.present? or @validation_errors.present?) ? I18n.t(:error) : I18n.t(:ok)
  json.simple_message "OTP verified successfuly"
  json.internal_message "OTP verified successfuly"
  json.data do
    json.otp @verify_delivery.deliverable_otp
    json.otp_status @verify_delivery.otp_status
  end
end