if @error.present?
  json.data Array.new
else
	json.data do
		json.categories @categories
		json.basic_units @basic_units
		json.menu_cards @menu_cards
	end
end