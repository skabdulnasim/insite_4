json.status (@error.present? or @validation_error.present?) ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  if @validation_error
    json.simple_message I18n.t(:duplicate_record_present)
    json.internal_message  I18n.t(:duplicate_record_present)
  else
    json.simple_message @error.present? ? I18n.t(:error_try_after_sometime) : I18n.t(:success_customer_state_transition_created)
    json.internal_message @error.present? ? @error.message : I18n.t(:success_customer_state_transition_created)
    json.error_code @log[:log_serial] if @error.present? and @log.present?
    json.error_url @log[:log_url] if @error.present? and @log.present?
  end
end 

if( @error.present? or @validation_error.present?)
  json.data Hash.new
else
  json.data  do
  	json.extract! @customer_state_transition, :customer_id, :customer_state_id, :user_id
  	json.customer_communication @customer_state_transition.customer_communications do |customer_communication|
  		json.extract! customer_communication,:user_id,:communication_medium,:communication_details
  	end
  end
end