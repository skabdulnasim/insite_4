json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_records_found_with_count, count: @return_items.count)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_records_found_with_count, count: @return_items.count)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Array.new
else
	json.data do
		json.count @return_items_count
		json.return_items @return_items do |return_item|
			json.extract! return_item, :id, :order_id, :order_detail_id
			json.product_id return_item.product.id
			json.item_name return_item.product.name
			json.quantity "#{return_item.quantity} #{return_item.product.basic_unit}"
			json.sku return_item.sku
			json.delivery_boy_id return_item.delivery_boy_id
			json.delivery_boy_name return_item.delivery_boy.name
			json.pick_from return_item.order.deliverable.delivery_address
			json.drop_at return_item.order.unit.address
			json.order_status return_item.order_status.name
			json.order_status_id return_item.return_status_id

			json.customer do 
				json.extract! return_item.order.customer, :id, :mobile_no, :email
				json.name "#{return_item.order.customer.customer_profile.firstname} #{return_item.order.customer.customer_profile.lastname}"
			end
		end
	end
end