json.extract! product, :id, :name, :local_name, :product_type, :category_id, :business_type, :hsn_code, :item_code, :brand_name, :mfr_name, :basic_unit_id
json.basic_unit product.basic_unit
json.caterory_name product.category.name
json.product_compositions product.product_compositions do |pc|
	json.extract! pc, :id, :basic_unit, :inventory_quantity, :product_id, :raw_product_id, :raw_product_quantity, :raw_product_unit, :raw_product_name
end