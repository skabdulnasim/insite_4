json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_requistion_not_found) : I18n.t(:success_requistion_found)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_requistion_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
	json.data Array.new
else
	json.data @store_requisition_logs do |store_requisition_log|
		user = User.find(store_requisition_log.store_requisition.user_id)
		_sender_name = "#{user.profile.firstname.humanize} #{user.profile.lastname.humanize}" if user.present? and user.profile.present?
		_sender_name ||= "#{user.email}" if user.present?
		_sender_name ||=""
		json.extract! store_requisition_log, :id, :store_requisition_id, :created_at
		json.status get_status(store_requisition_log.status)
		json.name store_requisition_log.store_requisition.name
		json.from_store store_requisition_log.from_store.name
		json.from_store_id store_requisition_log.from_store.id
		json.store_address store_requisition_log.from_store.address
		json.store_contact_number store_requisition_log.from_store.contact_number
		json.send_by _sender_name
		json.requistion_item store_requisition_log.store_requisition.store_requisition_metum.each do |item|
			json.extract! item, :product_id, :created_at
			json.requisition_ammount item.product_ammount
			json.product_name item.product.name
			json.product_unit item.product.basic_unit
			json.current_stock get_product_current_stock(@store.id,item.product_id)
		end
	end
end