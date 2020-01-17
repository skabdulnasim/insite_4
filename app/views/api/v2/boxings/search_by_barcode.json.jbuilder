if @error.present?
  json.data Hash.new
else
	if @product_found == 'yes'
		json.data do
			json.product_found @product_found
			json.stock_id @stock.id
			json.product_id @product.id
			_product_name = @product.package_component.present? ? @product.package_component.name : @product.name
			json.product_name _product_name
			json.product_basic_unit @product.basic_unit
			json.sku @stock.sku
			json.qty_in_pckg @qty_in_pckg if @qty_in_pckg.present?
			json.stock_checked @stock_checked
	  end 
	else
		json.data do
			json.product_found @product_found
		end
	end
end