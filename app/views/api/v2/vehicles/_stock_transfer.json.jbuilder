json.transaction_id object.id
json.date object.created_at
json.status object.status
json.vehicle_id object.vehicle_id
_from_store = object.from_store
_to_store = object.to_store
json.from_store do
	json.address _from_store.address
	json.contact_number _from_store.contact_number if _from_store.contact_number.present? ? _from_store.contact_number : "-"
	json.created_at _from_store.created_at
	json.id _from_store.id
	json.name _from_store.name
	json.pincode _from_store.pincode
	json.store_image _from_store.store_image
	json.store_priority _from_store.store_priority
	json.store_type _from_store.store_type
	json.unit_id _from_store.unit_id
end
json.to_store do
	json.address _to_store.address
	json.contact_number _to_store.contact_number if _to_store.contact_number.present? ? _to_store.contact_number : "-"
	json.created_at _to_store.created_at
	json.id _to_store.id
	json.name _to_store.name
	json.pincode _to_store.pincode
	json.store_image _to_store.store_image
	json.store_priority _to_store.store_priority
	json.store_type _to_store.store_type
	json.unit_id _to_store.unit_id
end	
json.products object.stock_transfer_meta.each do |meta_attribute|
	json.serial_no meta_attribute.id
	json.product_id meta_attribute.product_id
	json.product_name meta_attribute.product.name
	json.product_unit meta_attribute.product.basic_unit	
	json.product_amount meta_attribute.quantity_transfered
	json.product_image meta_attribute.product.product_image
	json.sku meta_attribute.sku
end