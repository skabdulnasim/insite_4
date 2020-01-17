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
	json.data @requisition_meta_details do |requisition_meta_detail|
		json.from_store_id requisition_meta_detail.from_store_id
		json.from_store requisition_meta_detail.store.name
		json.amount requisition_meta_detail.product_ammount
		json.product_unit requisition_meta_detail.product.basic_unit
		json.created_at requisition_meta_detail.created_at
	end
end