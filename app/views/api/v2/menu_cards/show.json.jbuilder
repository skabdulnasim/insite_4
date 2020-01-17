json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_menu_found)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_menu_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data do 
    json.extract! @menu_card, :id, :name, :master_menu_id, :mode, :scope, :section_id, :unit_id, :created_at, :updated_at, :menu_type, :operation_type, :menu_classification
    json.menu_product_count @menu_product_count
    # Adding menu categories 
    _image_size = "medium"
    _image_size = params[:image_size] if params[:image_size].present?
    if @resources.include? 'categories'
      json.categories @menu_card.parent_menu_categories do |category|
        json.extract! category, :id, :name, :description
        if category.image.present?
          json.menu_category_image "#{category.image.url(:"#{_image_size}")}"
        end
        _subcategories = category.submenucategories
        json.item_preferences category.item_preferences do |ip|
          json.extract! ip, :preference, :id
        end  
        # Filtering by subcategory_id
        _subcategories = _subcategories.by_id(params[:subcategory_id]) if params[:subcategory_id].present?
        json.sub_categories _subcategories do |subcategory|
          json.extract! subcategory, :id, :name, :description
          if subcategory.image.present?
            json.menu_category_image "#{subcategory.image.url(:"#{_image_size}")}"
          end
          # Adding Category Products as per resource
          if @resources.include? 'category_products'
            json.products subcategory.menu_products_variable_nil, partial: 'api/v2/menu_cards/menu_product', as: :menu_product
          end
        end
      end
    end
    if @resources.include? 'products'
      # Adding menu products
      if @category.present?
        json.products @menu_products, partial: 'api/v2/menu_cards/menu_product', as: :menu_product
      else
        json.products @menu_products, partial: 'api/v2/menu_cards/menu_product', as: :menu_product
      end
    end
    json.delivery_modes MenuProduct::DELIVERY_MODES
    json.commission_capping MenuProduct::COMMISSION_CAPPING_TYPE
  end
end