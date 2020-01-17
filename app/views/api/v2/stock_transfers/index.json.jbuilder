json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_stock_not_found) : I18n.t(:success_stock_found)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_stock_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
	json.data Array.new
else
	json.data do
		json.count @stock_transfers_count
		json.stock_transfers @stock_transfers do |stock_transfer|
			json.extract! stock_transfer, :vehicle_id, :status
			json.date stock_transfer.created_at
			json.transaction_id stock_transfer.id
			json.from_store_name stock_transfer.from_store.name
			json.from_store_address stock_transfer.from_store.address
			json.from_store_pincode stock_transfer.from_store.pincode
			json.from_store_contact_number stock_transfer.from_store.contact_number
			json.from_store_tin_no stock_transfer.from_store.tin_no
			json.from_store_tan_no stock_transfer.from_store.tan_no
			json.to_store_name stock_transfer.to_store.name
			json.to_store_address stock_transfer.to_store.address
			json.to_store_pincode stock_transfer.to_store.pincode
			json.to_store_contact_number stock_transfer.to_store.contact_number
			json.to_store_tin_no stock_transfer.to_store.tin_no
			json.to_store_tan_no stock_transfer.to_store.tan_no
			json.meta_attributes stock_transfer.stock_transfer_meta.each do |meta_attribute|
				json.id meta_attribute.id
				json.product_id meta_attribute.product_id
				json.product_name meta_attribute.product.name
				json.product_unit meta_attribute.product.basic_unit
				json.product_local_name meta_attribute.product.local_name
				json.tax_amount meta_attribute.tax_amount
				json.price_with_tax meta_attribute.price_with_tax
				json.price_without_tax meta_attribute.price_without_tax
				json.currency currency
				# json.quantity_transfered meta_attribute.quantity_transfered.to_s if params['transfer_type']=='debit'
				# json.quantity_received meta_attribute.quantity_received.to_s if params['transfer_type']=='credit'
				json.quantity_transfered meta_attribute.quantity_transfered.to_s
				json.quantity_received meta_attribute.quantity_received.to_s
				json.extract! meta_attribute, :sku, :batch_no, :model_number, :size_name, :color_name
				json.expiry_date meta_attribute.expery_date
			end
		end
	end
end
