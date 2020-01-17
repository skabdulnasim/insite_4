json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_requisition_send) : I18n.t(:success_requisition_send)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_requisition_send)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
	json.data Array.new
else
	json.data do
		json.extract! @req_log.store_requisition, :id, :created_at
		store = Store.find(@req_log.store_requisition.to_store)
		json.status get_status(@req_log.status)
		json.name @req_log.store_requisition.name
		json.to_store store.name
		json.to_store_id store.id
		json.store_address store.address
		json.store_contact_number store.contact_number
		json.store_tin_no store.tin_no
		json.store_tan_no store.tan_no
		json.store_pincode store.pincode
		json.store_latitude store.latitude
		json.store_longitude store.longitude
		json.store_gstn_no store.gstn_no
		json.store_pan_no store.pan_no
		json.store_contact_person store.contact_person
		json.store_user_id store.user_id
		json.requistion_item @req_log.store_requisition.store_requisition_metum.each do |item|
			json.extract! item, :product_id, :created_at
			json.requisition_ammount item.product_ammount
			json.product_name item.product.name
			json.product_unit item.product.basic_unit
		end
	end
end