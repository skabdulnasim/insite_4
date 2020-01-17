json.status (@error.present? or @validation_errors.present?) ? I18n.t(:error) : I18n.t(:ok)
json.messages do
	if @status_code.present?
		json.status_code @status_code 
		json.internal_message @status_message
		json.simple_message @status_message
	else
		json.status_code (@error.present? or @validation_errors.present?) ? 500 : 200
		json.internal_message (@error.present? or @validation_errors.present?) ? I18n.t(:error_try_after_sometime) : I18n.t(:success_store_created)
    json.simple_message @error.present? ? @error.message : I18n.t(:success_store_created)
    json.simple_message @validation_errors if @validation_errors.present?
  end
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?	
end

if @error.present? or @validation_errors.present?
  json.data Hash.new
else
	json.data @store
end