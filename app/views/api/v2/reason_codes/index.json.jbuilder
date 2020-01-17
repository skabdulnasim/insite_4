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
	json.model @model_action.master_model.name
	json.model_action @model_action.name
  json.master_models @reasons.each do |reason|
    json.extract!(reason, :id,:reason,:code,:stock_adjustment)
  end
end