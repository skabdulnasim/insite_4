if @error.present? or @validation_errors.present?
  json.data Hash.new
else
	json.data do
		json.extract! @boxing, :id, :name
  end 
end