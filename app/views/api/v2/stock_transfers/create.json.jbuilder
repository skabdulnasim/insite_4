json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_creating_stock_transfer) : I18n.t(:sucess_creating_stock_transfer)
  json.internal_message @error.present? ? @error.message : I18n.t(:sucess_creating_stock_transfer)
  json.internal_message @validation_errors if @validation_errors.present?
  json.internal_message @error.message if @error.present?
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
	json.data Hash.new
else
	json.data do
		json.extract! @stock_transfer, :id, :vehicle_id, :created_at, :status
		json.transaction_id @stock_transfer.id
		json.date @stock_transfer.created_at
		json.from_store @stock_transfer.from_store.name
		json.from_store_name @stock_transfer.from_store.name
		json.from_store_address @stock_transfer.from_store.address
		json.from_store_pincode @stock_transfer.from_store.pincode
		json.from_store_contact_number @stock_transfer.from_store.contact_number
		json.from_store_tin_no @stock_transfer.from_store.tin_no
		json.from_store_tan_no @stock_transfer.from_store.tan_no
		json.to_store @stock_transfer.to_store.name
		json.to_store_name @stock_transfer.to_store.name
		json.to_store_address @stock_transfer.to_store.address
		json.to_store_pincode @stock_transfer.to_store.pincode
		json.to_store_contact_number @stock_transfer.to_store.contact_number
		json.to_store_tin_no @stock_transfer.to_store.tin_no
		json.to_store_tan_no @stock_transfer.to_store.tan_no
		json.meta_attributes @stock_transfer.stock_transfer_meta.each do |meta_attribute|
			json.extract! meta_attribute, :id, :product_id, :quantity_transfered, :price_without_tax, :price_with_tax, :tax_amount
			json.product_name meta_attribute.product.name
		end
	end
end