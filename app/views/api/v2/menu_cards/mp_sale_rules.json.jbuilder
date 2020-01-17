if @error.present?
  json.data Hash.new
else
  json.data do
    json.mp_sale_rules @mp_sale_rules do |mp_sale_rule|
      json.extract! mp_sale_rule, :id, :menu_product_id, :sale_rule_id
      json.sale_rule_name mp_sale_rule.sale_rule.name
      json.valid_from mp_sale_rule.sale_rule.valid_from
      json.valid_to mp_sale_rule.sale_rule.valid_till
      json
    end
  end
end