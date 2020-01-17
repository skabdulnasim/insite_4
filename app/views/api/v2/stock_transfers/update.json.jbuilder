json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_stock_ship) : I18n.t(:success_stock_ship)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_stock_shipped)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
	json.data Hash.new
else
	json.data do
		json.extract! @stock_transfer, :id, :vehicle_id, :created_at, :updated_at, :status
		json.meta_attributes @stock_transfer.stock_transfer_meta.each do |meta_attribute|
			json.extract! meta_attribute, :id, :product_id, :quantity_received, :price_without_tax, :price_with_tax, :tax_amount
			json.product_name meta_attribute.product.name
		end
	end
end