json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_unit_found)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_unit_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data do
    json.extract! @product, :id, :name
    json.colors @product.color_products do |cp|
      json.id cp.color_id
      json.name cp.color_name
    end
    json.sizes @product.product_sizes do |ps|
      json.id ps.size_id
      json.name ps.size_name
    end
    json.product_units @product_units
  end
end