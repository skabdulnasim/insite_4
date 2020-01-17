if @error.present?
  json.data Hash.new
else
	json.data do
		json.item_removed @item_removed
	end
end