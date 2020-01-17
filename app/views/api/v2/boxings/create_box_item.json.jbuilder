if @error.present? or @validation_errors.present?
  json.data Hash.new
else
	json.data do
		if @product_found_in_package == 'yes'
			json.extract! @box_item, :id, :sku, :box_id, :product_id, :stock_id, :qty
			_product = Product.find(@box_item.product_id)
			_product_name = _product.package_component.present? ? _product.package_component.name : _product.name
			json.product_name _product_name
			json.product_basic_unit _product.basic_unit
			json.product_found_in_package @product_found_in_package
		else
			json.product_found_in_package @product_found_in_package
		end
  end 
end