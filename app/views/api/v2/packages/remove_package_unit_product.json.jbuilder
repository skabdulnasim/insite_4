if @error.present?
  json.data Hash.new
else
	json.data do
		json.package @package
	end
end