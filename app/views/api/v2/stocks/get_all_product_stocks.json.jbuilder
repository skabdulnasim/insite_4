json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_records_found_with_count, count: @paginated_stocks_count)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_records_found_with_count, count: @paginated_stocks_count)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
  json.count 	@stocks_count
end 
if @error.present?
  json.data Array.new
else
  #json.data @stocks, partial: 'api/v2/stocks/product_stock', as: :product
  if @business_type.present? && @business_type != 'by_catalog'
  	sku_product = {}
  	@stocks.each do |product|
			stocks = Stock.get_product(product.id).set_store(@store_id).available
			stocks.each do |stock|
				sku_product[stock.sku] = {'id'=>product.id,'name'=>product.name,'business_type'=>product.business_type,'basic_unit'=>product.basic_unit, 'product_category'=>product.category.id,'image'=>product.product_image, 'product_parent_category'=> product.category.parent ? product.category.parent : 0,'current_stock'=>Stock.available_stock(product.id, @store_id, stock.sku) }
			end
		end
		json.data sku_product do |sku,data|
			json.id data['id']
			json.name data['name']
			json.business_type data['business_type']
			json.basic_unit data['basic_unit']
			json.product_category data['product_category']
			json.sku sku
			json.image data['image']
			json.product_parent_category data['product_parent_category']
			json.current_stock data['current_stock']
		end
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
end