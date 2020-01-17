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
	json.data @purchase_orders do |pending_po|
		json.extract! pending_po, :id, :purchase_order_id, :status, :created_at
		json.vendor pending_po.purchase_order.vendor.name
		json.name pending_po.purchase_order.name
		json.po_status "Pending" if pending_po.status == '1'
		json.po_status "Received" if pending_po.status == '2'
		json.products pending_po.purchase_order.purchase_order_metum do |product|
			json.extract! product, :id, :product_id, :product_amount, :created_at
			json.product_name product.product.name
			json.basic_unit product.product.basic_unit
			json.currency currency
			json.vendor_price product.product.vendor_products.by_vendor_product(product.product_id,pending_po.purchase_order.vendor.id).first.price unless product.product.vendor_products.by_vendor_product(product.product_id,pending_po.purchase_order.vendor.id).first.nil? if pending_po.status == '1'
			if pending_po.status == '2'
				_stocks = pending_po.stocks.get_product(product.product_id).first
				if _stocks.present?
					mrp = _stocks.stock_price.mrp if _stocks.stock_price.present?
					total_price = _stocks.stock_price.total_price if _stocks.stock_price.present?
				else
					mrp = 0.00
					total_price = 0.00
				end	
				json.unit_price mrp
				json.total_price total_price
			end	
			json.color_status product.product.color_products.present?
			json.size_status product.product.product_sizes.present?
			json.expiry_date AppConfiguration.get_config_value('stock_expiry_date') == "enabled"
			json.purchase_order_item_descriptions product.purchase_order_metum_descrptions do |poid|
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
