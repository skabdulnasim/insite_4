json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
    json.simple_message @error.present? ? I18n.t(:error_try_after_sometime) : I18n.t(:success_record_found)
    json.internal_message @error.present? ? @error.message : I18n.t(:success_record_found)
    json.error_code @log[:log_serial] if @error.present? and @log.present?
    json.error_url @log[:log_url] if @error.present? and @log.present?
end 

if @error.present?
  json.data Hash.new
else
  json.data  @customer_transition do |transition|
  	json.extract! transition, :id,:customer_id, :customer_state_id, :recorded_at
  	json.state transition.customer_state.name
  end
end