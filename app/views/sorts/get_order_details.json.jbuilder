json.status @error.present? ? "error" : "ok"
json.messages do
  json.simple_message @error.present? ? "Error occured while loading data" : "#{@order_hash.count} datas loaded."
  json.internal_message @error.present? ? @error.message : "#{@order_hash.count} data loaded."
  json.error_code "" if @error.present?
  json.error_url "" if @error.present?
end
if @error.present?
  json.data Hash.new
else
  json.data do
    json.non_table_orders @order_hash[:non_table_orders]
    json.table_orders @order_hash[:table_orders]
    json.sorts @order_hash[:sorts]
  end
end 