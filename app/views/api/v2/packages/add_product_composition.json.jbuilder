if @error.present? or @validation_errors.present?
  json.data Hash.new
else
	if @product_found == 'yes'
		json.data do
			json.product_found @product_found
			json.extract! @product_composition, :id
	  end
	else
		json.data do
			json.product_found @product_found
		end
	end
end