if @error.present? or @validation_errors.present?
  json.data Hash.new
else
	json.data do
		json.extract! @package_unit, :id, :package_id, :parent, :unit_name
  end 
end