json.status @error.present? ? "error" : "ok"
json.messages do
  json.simple_message @error.present? ? "Error occured while loading data" : "#{@category_sales.length} datas loaded."
  json.internal_message @error.present? ? @error.message : "#{@category_sales.length} data loaded."
  json.error_code "" if @error.present?
  json.error_url "" if @error.present?
end
if @error.present?
  json.data Hash.new
else
  json.data do
    json.total_settlement number_to_currency(@settlement_data[:total_settlement].to_f, unit: '')
    json.cash_sale number_to_currency(@settlement_data[:cash_sale].to_f, unit: '')
    json.card_sale number_to_currency(@settlement_data[:card_sale].to_f, unit: '')
    json.loyalty_card_sale number_to_currency(@settlement_data[:loyalty_card_sale].to_f, unit: '')
    json.third_party_sale number_to_currency(@settlement_data[:third_party_sale].to_f, unit: '') 
	  json.product_sells @category_sales do |category_sale|
	    json.extract! category_sale, :menu_product_id, :product_id, :product_name, :total_sale, :quantity
	    json.sku ''
	  end 
  end 

end 
