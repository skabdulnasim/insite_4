json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_purchase_order_listing) : I18n.t(:success_purchase_order_listing)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_purchase_order_listing)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
	json.data Array.new
else
	json.data @purchase_orders do |purchase_order|
		json.extract! purchase_order, :id, :name, :purchase_order_code, :valid_from, :valid_till
		json.vendor purchase_order.vendor.name
		json.purchase_order_items purchase_order.purchase_order_metum do |po|
			json.extract! po, :id, :product_amount, :product_id, :purchase_order_id
			json.basic_unit po.product.basic_unit
			json.category_id po.product.category_id
			json.product_name po.product.name
			json.currency currency
			json.parent po.product.parent
			json.color_status po.product.color_products.present?
			json.size_status po.product.product_sizes.present?
			json.purchase_order_item_descriptions po.purchase_order_metum_descrptions do |poid|
				json.extract! poid, :id, :color_id, :size_id, :product_id, :purchase_order_metum_id, :quantity, :purchase_order_id
				if poid.color_id.present?
					json.color_name poid.color.name
				else
					json.color_name ''
				end	
				if poid.size_id.present?
					json.size_name poid.size.name
				else
					json.size_name ''
				end		
			end
		end
	end
end