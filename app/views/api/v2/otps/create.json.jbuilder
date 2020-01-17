json.status (@error.present? or @customer.present?) ? I18n.t(:error) : I18n.t(:ok)
json.messages do
	if @phone_number.present?
  	json.simple_message @error.present? ? I18n.t(:error_try_after_sometime) : I18n.t(:success_otp_generated)
  	json.internal_message @error.present? ? @error.message : I18n.t(:success_otp_generated)
  elsif @customer.present?
  	json.simple_message @error.present? ? I18n.t(:error_try_after_sometime) : I18n.t(:customer_exists)
  	json.internal_message @error.present? ? @error.message : I18n.t(:customer_exists)
  end	
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data do
  	if @phone_number.present?		
    	json.extract! @phone_number, :id, :phone_number, :otp
    elsif @customer.present?
    	json.extract! @customer, :id, :mobile_no
    end
  end  
end