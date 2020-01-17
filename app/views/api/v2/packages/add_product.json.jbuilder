# if @error.present? or @validation_errors.present?
#   json.data Hash.new
# else
# 	json.data do
# 		json.extract! @product, :id, :name, :basic_unit_id
#   end 
# end
json.data @product