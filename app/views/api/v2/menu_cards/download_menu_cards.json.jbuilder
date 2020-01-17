json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_record_found)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_record_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data do
  	json.menu_card_url "/menu_cards/"
  	# Adding menu category    
    json.categories @menu_card.parent_menu_categories do |category|
      json.extract! category, :id, :name, :menu_category_image, :description
      _subcategories = category.submenucategories
      json.item_preferences category.item_preferences do |ip|
        json.extract! ip, :preference, :id
      end  
      json.sub_categories _subcategories do |subcategory|
        json.extract! subcategory, :id, :name, :menu_category_image, :description
      end
    end
    json.file_csv @file_array
  end
end