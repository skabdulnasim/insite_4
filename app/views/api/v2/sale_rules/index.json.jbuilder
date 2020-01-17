json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_records_found_with_count, count: @sale_rules.count)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_records_found_with_count, count: @sale_rules.count)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Array.new
else
  json.data do
  	json.count @sale_rules.count
  	json.sale_rules @sale_rules do |sale_rule|
    	json.extract! sale_rule, :id, :name, :status, :sale_rule_type, :valid_from, :valid_till, :specific_type
    	json.rule_input do
    		json.extract! sale_rule.sale_rule_input, :id, :amount, :sale_rule_input_type, :buy_qty
    	end
    	json.rule_output do
    		json.extract! sale_rule.sale_rule_output, :id, :amount, :sale_rule_output_type, :amount_type, :get_qty
    	end
      if sale_rule.lots.present?
        json.lots sale_rule.lots do |lot|
          json.extract! lot, :id
        end
      else
        json.lots Array.new
      end  
      if sale_rule.menu_products.present?
        json.products sale_rule.menu_products do |menu_product|
          json.extract! menu_product, :id
        end
      else
        json.products Array.new
      end 
      if sale_rule.menu_categories.present?
        json.products sale_rule.menu_categories do |menu_category|
          json.extract! menu_category, :id
        end
      else
        json.categories Array.new
      end 
  	end
  end	
end