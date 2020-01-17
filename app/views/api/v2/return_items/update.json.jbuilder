json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_try_after_sometime) : I18n.t(:success_return_item_updated)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_return_item_updated)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data do
    json.extract! @return_item, :id, :order_id, :order_detail_id
    json.status @return_item.order_status.name
    json.picked_by DeliveryBoy.find(@return_item.picked_by).name
    json.product_id @return_item.product.id
    json.item_name @return_item.product.name
    json.quantity "#{@return_item.quantity} #{@return_item.product.basic_unit}"
    json.sku @return_item.sku
    json.delivery_boy_id @return_item.delivery_boy_id
    json.delivery_boy_name @return_item.delivery_boy.name
    json.pick_from @return_item.order.deliverable.delivery_address
    json.drop_at @return_item.order.unit.address
    json.customer do 
      json.extract! @return_item.order.customer, :id, :mobile_no, :email
      json.name "#{@return_item.order.customer.customer_profile.firstname} #{@return_item.order.customer.customer_profile.lastname}"
    end
  end  
end