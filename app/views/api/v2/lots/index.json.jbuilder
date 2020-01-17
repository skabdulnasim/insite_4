json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_records_found_with_count, count: @lots.count)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_records_found_with_count, count: @lots.count)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Array.new
else
  json.data do
  	json.count @count
	  json.lots @lots do |lot|
	    json.extract! lot, :id,  :menu_card_id, :menu_product_id, :sell_price, :sell_price_without_tax, :sku, :stock_qty, :tax_group_id, :product_id, :expiry_date, :stock_id, :procured_price, :mrp, :color_name, :size_name, :model, :color_id, :size_id, :lot_desc
			json.basic_unit lot.product.basic_unit
	  end
	end  
end