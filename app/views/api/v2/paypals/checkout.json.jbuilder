if @result.present?
	json.status (@result.success? and @result.present?) ? I18n.t(:ok) : I18n.t(:error)
	json.messages do
	  json.simple_message @result.success? ? I18n.t(:paypal_payment) : I18n.t(:error_try_after_sometime)
	  json.internal_message @result.success? ? I18n.t(:paypal_payment) : @result.message
	  json.error_code @log[:log_serial] if @error.present? and @log.present?
	  json.error_url @log[:log_url] if @error.present? and @log.present?
	end
else
	json.status I18n.t(:error)
	json.messages do
	  json.simple_message I18n.t(:error_try_after_sometime)
	  json.internal_message @error.message
	end
	json.data Hash.new
end	
if @result.present?
	if @result.success?
	  json.data do
	  	json.transaction_id @result.transaction.id
	  	json.created_at @result.transaction.created_at.strftime("%d-%m-%Y, %I:%M %p")
		end
	else
		json.data Hash.new 
	end
else	
	json.data Hash.new 
end