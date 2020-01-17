json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_records_found_with_count, count: @products.count)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_records_found_with_count, count: @products.count)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Array.new
else
  #json.data @products do |product|
    #json.extract! product, :id, :name, :basic_unit
    #json.image product.product_image
  #end
  json.data do
    json.count @product_count
    json.categories @root_categorys do |r_c|
      json.extract! r_c, :id, :name
      json.sub_categories r_c.subcategories do |cat|
        json.extract! cat, :id, :name
      end
    end
    json.products @products, partial: 'api/v2/products/product', as: :product
  end
end