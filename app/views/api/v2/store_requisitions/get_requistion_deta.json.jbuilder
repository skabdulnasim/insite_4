json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_summary_details_not_found) : I18n.t(:success_summary_details_found)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_summary_details_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
	json.data Array.new
else
	json.data do
		json.extract! @log_details, :id, :store_id, :from_store_id, :store_requisition_id, :status, :product_count, :sent_product_count, :created_at, :updated_at, :sent_product_details
		json.business_type @log_details.store_requisition.business_type
		json.meta_attributes @log_details.store_requisition.store_requisition_metum.each do |meta_attribute|
			json.extract! meta_attribute, :id, :product_id, :requisition_id, :product_ammount, :product_unit_id, :created_at, :updated_at, :color_id, :size_id
			json.color_name meta_attribute.color_id.present? ? meta_attribute.color.name : ''
			json.size_name meta_attribute.size_id.present? ? meta_attribute.size.name: ''
			json.product_name meta_attribute.product.name
			# json.product_current_stock get_product_current_stock(@store_id, meta_attribute.product_id)
			json.product_current_stock Stock.product_variation_available_stock(meta_attribute.product_id,@log_details.store_id,nil,meta_attribute.color_id,meta_attribute.size_id)
			json.basic_unit meta_attribute.product.basic_unit
		end
	end
end