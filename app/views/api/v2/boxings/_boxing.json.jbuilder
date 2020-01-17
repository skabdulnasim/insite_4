json.extract! boxing, :id, :name, :boxing_source_type, :boxing_source_id, :store_id, :created_at
json.boxes boxing.boxes do |box|
  json.extract! box, :id, :sku, :boxing_id, :product_id, :stock_id
  json.box_product_name box.product.name 
  # Adding box items
  json.box_items box.box_items do |item|
    json.extract! item, :id, :sku, :box_id, :product_id, :stock_id, :qty
    json.box_item_name item.product.package_component.name 
    json.product_basic_unit item.product.basic_unit
  end
end