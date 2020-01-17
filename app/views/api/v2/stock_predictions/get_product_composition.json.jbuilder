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
  json.data  @products do |product|
    _product = Product.find(product)
    json.extract! _product, :id, :name, :basic_unit
    json.product_compositions _product.product_compositions do |product_composition|
      compositin_name = Product.find(product_composition.raw_product_id)
      json.extract! product_composition, :id, :product_id, :raw_product_id, :raw_product_quantity, :raw_product_unit, :inventory_quantity, :basic_unit
      json.composition_product_name compositin_name.name
    end
  end  
end