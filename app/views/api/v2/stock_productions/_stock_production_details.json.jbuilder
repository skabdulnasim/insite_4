json.stock_production stock_production
json.stock_production_metas stock_production.stock_production_metas do |stock_production_meta|
	stock_production_meta.ingredients = JSON.parse(stock_production_meta.ingredients)
  stock_production_meta.ingredients.each do |ingredient|
    ingredient['raw_product_basic_unit'] = Product.find(ingredient['raw_product_id']).basic_unit
  end
  stock_production_meta['product_basic_unit'] = Product.find(stock_production_meta['product_id']).basic_unit
	json.stock_production_meta stock_production_meta
	json.stock_production_raws stock_production_meta.stock_production_raws do |stock_production_raw|
		stock_production_raw['product_basic_unit'] = Product.find(stock_production_raw['product_id']).basic_unit
    stock_production_raw['target_product_basic_unit'] = Product.find(stock_production_raw['target_product_id']).basic_unit
    json.stock_production_raw stock_production_raw
	end
	json.stock_production_meta_processes stock_production_meta.stock_production_meta_processes do |stock_production_meta_process|
		json.stock_production_meta_process stock_production_meta_process
	end
end