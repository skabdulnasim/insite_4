if @error.present?
  json.data Hash.new
else
	json.data do
		json.tax_groups @tax_groups do |t_g|
			json.extract! t_g, :id, :name
		end
	end
end