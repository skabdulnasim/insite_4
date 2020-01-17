json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_records_found_with_count, count: @menu_product_count)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_records_found_with_count, count: @menu_product_count)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Array.new
else
	json.data do
		json.count @menu_product_count
  	json.products @menu_products do |product|
    	json.id product.id 
    	json.name product.name
    	json.basic_unit product.basic_unit
    	_sub_products = ProductComposition::get_sub_products(product.id)
    	json.ingredients _sub_products do |sub_product|
    		_sub_product_details = ProductComposition::get_product_details_by_id(sub_product['raw_product_id'])
    		json.extract! _sub_product_details, :id, :name, :basic_unit
    		json.extract! sub_product, :raw_product_quantity

        json.current_stock get_product_current_stock(@store_id, sub_product.raw_product_id)
        product_current_stock_cost = get_product_current_stock_cost(@store_id, sub_product.raw_product_id)
    		cost = product_current_stock_cost.present? ? product_current_stock_cost.current_price : 0
        if cost.nil?
          json.cost 0
        else
          json.cost cost
        end
        # json.product_unit sub_product.product_unit.name
        json.currency currency
    	end
      _processes = ProcessComposition::get_process_composition(product.id)
      json.processes _processes do |process_details|
        json.extract! process_details, :production_process_id, :production_process_name, :duration
        json.cost process_details.production_process.cost
        json.currency currency
      end
    end
  end
end