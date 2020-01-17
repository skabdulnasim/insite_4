json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_records_found_with_count, count: @stores_count)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_records_found_with_count, count: @stores_count)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Array.new
else
  # json.data @stores
  json.data do
  	json.count @store_products_count

    json.categories Category.get_root_categories do |category|
      json.extract! category, :id, :name
      _subcategories = category.subcategories
      json.sub_categories _subcategories do |subcategory|
        json.extract! subcategory, :id, :name
      end
    end
    
    json.store_products @store_products do |store_product|
      json.extract! store_product, :id, :product_id, :store_id
      json.product_name store_product.product.name
      json.basic_unit store_product.product.basic_unit
      _image_size = "thumb"
      _image_size = params[:image_size] if params[:image_size].present?
      _image = store_product.product.product_images.first
      _image_url = _image.present? ? "#{_image.image.url(:"#{_image_size}")}" : ""
      
      json.product_image _image.present? ? "#{_image.image_file_name}" : ""
      json.product_image_url _image_url
      json.product_description store_product.product.short_description
      json.category_id store_product.product.category_id
    end
  end
end