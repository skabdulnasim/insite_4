if @error.present? or @validation_errors.present?
  json.data Hash.new
else
	json.data do
		json.extract! @box, :id, :sku, :boxing_id, :product_id, :stock_id
		_product = Product.find(@box.product_id)
		_product_name = _product.package_component.present? ? _product.package_component.name : _product.name
		json.product_name _product_name
		json.package_name @box.boxing.boxing_source.name
  end 
end