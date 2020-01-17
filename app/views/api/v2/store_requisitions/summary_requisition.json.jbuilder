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
	summary_requisitions = {}
	@requestions.each do |data|
	  product_details = StoreRequisitionMetum.get_product_details(data,@rq_date).order("product_id")
	  product_details.each do |product|
	    if  summary_requisitions.has_key? product.product_id
	      summary_requisitions[product.product_id]["total_amount"] = summary_requisitions[product.product_id]["total_amount"].to_f+product.total_amount.to_f
	    else
	      summary_requisitions[product.product_id] = {'total_amount'=>product.total_amount.to_f}
	    end
	  end  
	end
	json.data summary_requisitions do |product_id,data|
		product = Product.find(product_id)
		json.product_id product_id
		json.product_name product.name
		json.total_requisition_ammount data['total_amount']
		json.current_stock get_product_current_stock(product_id,@store.id)
		json.product_basic_unit product.basic_unit 
		requisition_meta_details = LogItem.set_product_in(product_id).na_requisitions.store_requistion(@store.id).by_created_at(@rq_date) if params[:resources].present? 
		if requisition_meta_details.present?
			json.requisition_meta_details requisition_meta_details do |requisition_meta_detail|
				json.from_store_id requisition_meta_detail.from_store_id
				json.from_store requisition_meta_detail.store.name
				json.amount requisition_meta_detail.product_ammount
				json.product_unit requisition_meta_detail.product.basic_unit
				json.created_at requisition_meta_detail.created_at
			end
		end	
	end
end