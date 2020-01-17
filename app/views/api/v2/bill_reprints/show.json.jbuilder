json.status (@error.present? or @validation_errors.present?) ? I18n.t(:error) : I18n.t(:ok)
json.messages do
	json.simple_message (@error.present? or @validation_errors.present?) ? I18n.t(:error_try_after_sometime) : I18n.t(:success_data_fetched)
  	json.internal_message I18n.t(:success_data_fetched)
  	json.internal_message @validation_errors if @validation_errors.present?
  	json.internal_message @error.message if @error.present?
  	json.error_code @log[:log_serial] if @error.present? and @log.present?
  	json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present? or @validation_errors.present?
  json.data Hash.new
else
		json.data @reprint_details do |reprint_data|
			json.extract! reprint_data, :id, :bill_id, :user_id, :reprint_reason
      json.recorded_at reprint_data.recorded_at #strftime("%d-%m-%Y, %I:%M %p")
      json.user_email reprint_data.user.email

  	end 
end