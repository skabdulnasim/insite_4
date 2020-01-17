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
    json.count @stocks_count
    json.stocks @stocks do |stock|
      json.extract! stock, :id, :product_id, :store_id, :stock_transaction_id, :stock_transaction_type, :stock_credit, :stock_debit, :created_at
      json.from_store_id stock.stock_transaction.from_store.id
      json.from_store_name stock.stock_transaction.from_store.name
      json.to_store_id stock.stock_transaction.to_store.id
      json.to_store_name stock.stock_transaction.to_store.name
    end
  end  
end