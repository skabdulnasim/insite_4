json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_records_found_with_count, count: @paginated_stocks_count)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_records_found_with_count, count: @paginated_stocks_count)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
  json.count @stocks_count
end 
if @error.present?
  json.data Array.new
else
	if AppConfiguration.get_config_value('barcode_on_catalog_product') != 'enabled'
		json.data(@stocks) do |product|
			json.extract! product, :id, :name, :business_type, :basic_unit, :local_name
			json.product_category product.category.id
			json.sku ''
			json.image product.product_image
			json.product_parent_category product.category.parent ? product.category.parent : 0
			json.current_stock StockUpdate.current_stock(@store_id,product.id)
		end
	else
		json.data(@stocks) do |stock|
			_product = stock.product
			json.extract! _product, :id, :name, :business_type, :basic_unit, :local_name
			json.product_category _product.category.id
			json.sku stock.sku
			json.image _product.product_image
			json.product_parent_category _product.category.parent ? _product.category.parent : 0
			# json.current_stock StockUpdate.current_stock(@store_id,product.id)
			json.current_stock stock.total_available_stock
			json.extract! stock, :sku, :expiry_date, :batch_no 
		end
	end
end