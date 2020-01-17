json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? @error.message : "Request processed successfully"
  json.internal_message @error.present? ? @error.message : "Request processed successfully"
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Array.new
else
  json.data @stocks do |stock|
    menu_product = @catalog.menu_products.set_product(stock.product_id).set_store(stock.store_id).first
    if menu_product.present?
      json.extract! stock, :id, :available_stock, :bussiness_type, :price, :store_id, :sku
      json.product_name stock.product.name
      json.catalog_id @catalog.id
      json.menu_product_id menu_product.id 
      json.properties do
        json.extract! stock.stock_defination, :making_cost, :received_product_unit, :sell_price, :wastage, :weight, :sku, :description
      end
    end
  end
end