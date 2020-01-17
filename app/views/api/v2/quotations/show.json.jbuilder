json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_try_after_sometime) : I18n.t(:success_record_found)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_record_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data @quotation
  json.advance_payments @quotation.advance_payments
  json.orders @quotation.orders do |order|
    json.extract! order, :id, :order_sr_no
    json.order_items order.order_details do |item|
      json.extract! item, :id, :product_id, :menu_product_id, :product_name, :product_price
    end
  end
end