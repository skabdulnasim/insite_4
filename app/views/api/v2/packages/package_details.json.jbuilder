if @error.present?
  json.data Hash.new
else
	package_unit_ids = []
	@package.package_units.map { |e| package_unit_ids.push e.id }
  package_unit_products = PackageUnitProduct.set_package_unit_in(package_unit_ids) if package_unit_ids.present?
	total_product_count = package_unit_products.present? ? package_unit_products.count : 0
	
	json.data do
		json.extract! @package, :id, :name
		json.total_product_count total_product_count
  end 
end