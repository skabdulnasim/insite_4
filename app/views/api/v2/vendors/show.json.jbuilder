json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_listing_vendor_product) : I18n.t(:success_listing_vendor_product)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_listing_vendor_product)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
  json.count @product_count
end
if @error.present?
	json.data Hash.new
else
	json.data do
		json.id @vendor.id
		json.name @vendor.name
		json.phone @vendor.phone
		json.address @vendor.address
		json.products @products do |product|
			_vendor_product = product.vendor_products.by_vendor(@vendor.id).first
			_vendor_product_price = _vendor_product.price.present? ? _vendor_product.price : 0
			json.product_id product.id
			json.price _vendor_product_price
			json.product_name product.name
			json.business_type product.business_type
			json.product_basic_unit_id product.basic_unit_id
			json.product_basic_unit product.basic_unit
			json.current_stock get_product_current_stock(@store_id,product.id)
			json.image_url product.product_image
			json.currency currency
			json.category_id product.category_id
			json.parent_category_id product.category.parent
			json.color_status product.color_products.present?
			json.size_status product.product_sizes.present?
			json.expiry_date AppConfiguration.get_config_value('stock_expiry_date') == "enabled"
		end
	end
end