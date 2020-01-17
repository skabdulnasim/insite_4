json.status @error.present? ? "error" : "ok"
json.messages do
  json.simple_message @error.present? ? "Error occured while loading data" : "data loaded successfully"
  json.internal_message @error.present? ? @error.message : "data loaded successfully"
  json.error_code "" if @error.present?
  json.error_url "" if @error.present?
end
if @error.present?
  json.data Hash.new
else
	json.data do
		json.order_id @order_scope.id
    json.order_status_id @order_scope.order_status_id
    json.order_subtotal @order_scope.order_subtotal
    json.order_time @order_scope.created_at.strftime("%I:%M %P")
    json.source @order_scope.source
    json.deliverable_id @order_scope.deliverable_id
    json.deliverable_type @order_scope.deliverable_type
    json.approved_orders @order_scope.order_details.where('status=?',"approved").count
    json.preparing_orders @order_scope.order_details.where('status=?',"preparing").count 
    json.prepared_orders @order_scope.order_details.where('status=?',"prepared").count
    if @order_scope.deliverable_type == "Section"
      json.waiter_id @order_scope.consumer[:id]
      json.waiter_name @order_scope.consumer.profile[:firstname] +" "+ @order_scope.consumer.profile[:lastname]
    elsif @order_scope.deliverable_type == "Table"
      json.table_id @order_scope.deliverable[:id]
      json.table_name @order_scope.deliverable[:name]
      json.table_status @order_scope.deliverable[:status]
      json.waiter_id @order_scope.consumer[:id]
      json.waiter_name @order_scope.consumer.profile[:firstname] +" "+ @order_scope.consumer.profile[:lastname]      
    end
    order_details = @order_scope.order_details
    details_array = Array.new
    order_details.each do |order_detail|
      details_hash = {}
      details_hash[:product_id]       = order_detail[:product_id]
      details_hash[:product_name]     = order_detail[:product_name]
      details_hash[:status]           = order_detail[:status]
      details_hash[:quantity]         = order_detail[:quantity]
      details_hash[:order_item_time]  = order_detail[:created_at].strftime("%I:%M %P")
      details_hash[:sort_id]          = order_detail[:sort_id]
      if @order_scope.deliverable_type == "Table"
        details_hash[:source]         = "table"
      else
        details_hash[:source]         = "non-table"
      end
      details_hash[:order_details_id] = order_detail[:id]
      details_array.push details_hash
    end
    json.order_details details_array
	end
end