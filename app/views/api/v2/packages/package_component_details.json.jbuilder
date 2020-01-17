if @error.present?
  json.data Hash.new
else	
	json.data do
		json.extract! @package_component, :id, :name, :basic_unit_id, :category_id
  end 
end