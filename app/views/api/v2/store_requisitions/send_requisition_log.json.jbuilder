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
	json.data @sent_requisitions do |sent_requisition|
		json.extract! sent_requisition, :id, :created_at
		json.status get_status(sent_requisition.status)
		json.name sent_requisition.store_requisition.name
		json.to_store sent_requisition.store.name
		json.to_store_id sent_requisition.store.id
		json.store_address sent_requisition.store.address
		json.store_contact_number sent_requisition.store.contact_number
		json.store_tin_no sent_requisition.store.tin_no
		json.store_tan_no sent_requisition.store.tan_no
		json.requistion_item sent_requisition.store_requisition.store_requisition_metum.each do |item|
			json.extract! item, :product_id, :created_at
			json.requisition_ammount item.product_ammount
			json.product_name item.product.name
			json.product_unit item.product.basic_unit
		end
	end
end