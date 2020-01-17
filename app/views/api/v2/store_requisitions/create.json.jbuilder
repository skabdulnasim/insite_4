json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_requisition_creation) : I18n.t(:success_requisition_creation)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_requisition_creation)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
	json.data Array.new
else
	json.data do
		json.extract! @store_requisition, :id, :name, :requisition_code, :store_id, :to_store, :unit_id, :user_id, :valid_from, :valid_till
	end
end