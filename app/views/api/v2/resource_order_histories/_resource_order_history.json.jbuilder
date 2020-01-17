json.extract! resource_order_history, :id, :latitude, :longitude, :recorded_at, :resource_id, :unit_id, :user_id, :device_id
# Adding order items
json.resource_order_history_items resource_order_history.resource_order_history_details do |item|
  json.extract! item, :id, :product_id, :menu_product_id, :product_name, :remarks, :created_at, :updated_at
end
