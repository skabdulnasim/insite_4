json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
    json.simple_message @error.present? ? I18n.t(:error_try_after_sometime) : I18n.t(:success_products_bin_found)
    json.internal_message @error.present? ? @error.message : I18n.t(:success_products_bin_found)
    json.error_code @log[:log_serial] if @error.present? and @log.present?
    json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present? or !@bins.present?
  json.data do
    json.stock_credit @stock_received
    json.bins Hash.new
  end
else
  json.data  do
    json.product_name @bins.first.product.name
    json.stock_credit @stock_received
    json.bins  @bins.each do |bin|
        json.extract! bin, :bin_unique_id, :product_quantity
    end
  end
end