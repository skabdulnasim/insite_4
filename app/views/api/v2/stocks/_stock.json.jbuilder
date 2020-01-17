json.extract! stock, :id, :product_id, :product_name, :sku, :available_stock, :weight, :making_cost, :description, :sell_price_of_item
json.product_type stock.product_sell_type
if stock.product.by_bulk_weight?
  _composition = stock.product.product_compositions.first
  json.product_unit_id _composition.raw_product_unit
  json.product_unit_name _composition.product_unit.short_name
else
  json.product_unit_id stock.received_product_unit
  json.product_unit_name stock.stock_defination.present? ? stock.stock_defination.product_unit_short_name : ''
end