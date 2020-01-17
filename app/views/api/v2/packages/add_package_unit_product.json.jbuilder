if @error.present? or @validation_errors.present?
  json.data Hash.new
else
	json.data do
		json.extract! @package_unit_product, :id, :package_unit_id, :product_id, :quantity
  end 
end