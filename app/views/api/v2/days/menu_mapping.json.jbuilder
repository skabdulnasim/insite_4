json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  if @menu_merge_disabled.present?
    json.simple_message @menu_merge_disabled
  else
    json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_record_found)
    json.internal_message @error.present? ? @error.message : I18n.t(:success_record_found)
    json.error_code @log[:log_serial] if @error.present? and @log.present?
    json.error_url @log[:log_url] if @error.present? and @log.present?
  end  
end 
if @error.present? || @menu_merge_disabled.present?
  json.data Hash.new
else
  json.data do
    json.merge_sections @merge_sections do |ms|
      section = Section.find(ms.merge_section_id)
      json.name section.name
      json.id section.id
      menu_cards = MenuMapping.by_day(@day.id).by_merge_section(section.id).active.by_unit_id(@unit_id)
      #menu_cards = MenuMapping.by_day(@day.id).by_merge_section(section.id).active
      json.menu_cards menu_cards do |mc|
        menu_card = MenuCard.find(mc.menu_card_id)
        json.menu_card_id mc.menu_card_id
        json.name menu_card.name
      end
    end
    
  end
end