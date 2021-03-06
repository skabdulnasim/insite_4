json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_purchase_order_found)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_purchase_order_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data do 
  	json.stock_purchases @stock_purchases do |stock_purchase|
    	json.extract! stock_purchase, :id
    	json.status 'received'
    	json.store_name stock_purchase.store.name
    end	
  end
end