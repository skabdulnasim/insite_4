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
  if @stock_check_on_order == 'enabled'
    json.data @stocks do |stock|
      menu_product = @catalog.menu_products.set_product(stock.product_id).set_store(stock.store_id).first
      if menu_product.present?
        json.extract! stock, :id, :available_stock, :bussiness_type, :price, :store_id, :sku
        json.product_name stock.product.name
        json.catalog_id @catalog.id
        json.menu_product_id menu_product.id 
        if stock.stock_defination.present?
          json.properties do
            json.extract! stock.stock_defination, :making_cost, :received_product_unit, :sell_price, :wastage, :weight, :sku, :description
          end
        else
          json.properties do
            json.making_cost menu_product.procured_price
            json.sell_price menu_product.sell_price
          end
        end  
      end
    end
  else
    json.data do
      if @product.present?
        json.product_found 'yes'
        if @menu_product.present?
          json.menu_product_found 'yes'
          json.product_name @menu_product.product.name
          json.catalog_id @catalog.id
          json.menu_product_id @menu_product.id
          json.properties do
            json.making_cost @menu_product.procured_price
            json.sell_price @menu_product.sell_price
          end
        else
          json.menu_product_found 'no'
        end
      else
        json.product_found 'no'
      end
    end
  end
end