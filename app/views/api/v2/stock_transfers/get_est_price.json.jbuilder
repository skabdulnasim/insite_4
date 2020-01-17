json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_est_price_not_found) : I18n.t(:success_est_price_found)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_est_price_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
	json.data Array.new
else
	json.data @product_details do |product_detail|
		json.est_price get_estimated_price(product_detail["product_id"], @store_id, product_detail["quantity"])
		json.quantity product_detail["quantity"]
		json.product_id product_detail["product_id"]
		json.product_name product_detail["product_name"]
		json.product_image product_detail["product_image"]
		json.product_unit product_detail["product_unit"]
		json.currency currency
		json.tax_group @tax_groups.each do |tax_group|
			json.extract! tax_group, :id
			json.name "#{tax_group.name}""(#{tax_group.total_amnt})%" 
		end
	end
end