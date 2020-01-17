module MenuCardsHelper

  def added_tags(menu_product)
    saved_menu_product_tags_id = Array.new
    menu_product.tags.uniq.each do |tag|
      saved_menu_product_tags_id.push tag[:id]
    end
    return saved_menu_product_tags_id
  end

  def menu_card_index_api
    #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
    api :GET, '/menu_cards.json', "Get all menu cards"
    param :unit_id, String, :desc => "Unit ID", :required => false
    param :device_id, String, :desc => "YOTTO05", :required => false
    error :code => 401, :desc => "Unauthorized"
    description "This will return the followings:
    created_at = The creation date.
    id = menu card id[TAB]
    mode = 0 or 1 as visible or not visible
    name = Menu card Name[TAB]
    trash = deleted or not
    unit_id = this menu card is belongs to this unit
    updated_at: ""
    valid_from: ""
    valid_till: ""
    
    menu_categories_variable_nil: [
        {
        created_at: category creation date
        description: category description[TAB]
        id: category_id[TAB]
        menu_card_id: this category is belongs to this menu card[TAB]
        name: category name[TAB]
        parent: parent of this category[TAB]
        unit_id: this menu card is belongs to this unit,
        updated_at: "",
        submenucategories: the childres of this category[TAB]   } ]
        
    menu_products_variable_nil: [
        {    
          created_at: menu product creation date
          id: menu_product_id[TAB]
          menu_card_id: this menu product is belongs to this menu card[TAB]
          menu_category_id: menu product category id[TAB]
          mode: 0 for hide 1 for show[TAB]
          procured_price: procured price for this menu product
          product_id: product id for this menu product id
          sell_price: sellprice of this menu product[TAX]
          sell_price_without_tax: sellprice without tax of this menu product[TAX]
          stock_qty: null
          stock_status: 1
          updated_at: 
          variable_id: null
          variants: [ ]
          products: {
            basic_unit: inventory unit of the product
            business_type: null,
            category_id: product category id
            created_at: 
            id: product_id
            name: product name
            parent: product parent,
            physical_type_id: product physical type id
            product_image: product image[TAB]
            product_type: simple/variable
            short_name: produc short name
            sku: 
            unittype_id: unit type id
            updated_at: 
            valid_from: null
            product_meta: [{
              created_at:
              id: 
              meta_key: product meta key like tax, raw etc
              meta_value: product meta value as an array
              product_id: product id
              updated_at: 
            }]
          }
        }
        meu_category: {
          created_at: 
          description: category description
          id: menu category id[TAB]
          menu_card_id: menu card id[TAB]
          name: menu category name[TAB]
          parent: parent of this menu category[TAB]
          unit_id: 2,
          updated_at: 
          }
          
        combination_types: [{
          created_at: 
          id: combination_types id
          name: combination type name[TAB]
          updated_at: 
          menu_product_combinations: [
            {
            combination_type_id: 1,
            combinations_rule_id: customization rule id[TAB]
            created_at: 
            id: menu_product_combinations_id
            menu_product_id: menu_product_id
            price: price for this combination[TAB]
            product_id: 1,
            updated_at: 
            products: {
              basic_unit: inventory unit of the product
              business_type: null,
              category_id: product category id
              created_at: 
              id: product_id
              name: product name
              parent: product parent,
              physical_type_id: product physical type id
              product_image: product image[TAB]
              product_type: simple/variable
              short_name: produc short name
              sku: 
              unittype_id: unit type id
              updated_at: 
              valid_from: null
              }
            }]
            
        combinations_rules: [{
          created_at: 
          id: combinations_rules id
          max_qty: maximum combination products[TAB]
          min_qty: minimum combination products[TAB]
          name: combination name[TAB]
          updated_at: 
          }]
        }]
      ]
    formats ['json', 'html']"
    #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  end
  def panel_class(mode)
    case mode
      when 0
        return "panel-danger"
      when 1
        return "panel-success"
      else
        return "panel-warning"
    end
  end

  def load_menu_category_list(categories, f)
    categories.each do |cat|
      concat (content_tag(:li){
        concat(content_tag(:h5, cat.name))
        concat(link_to_add_fields "Add category under #{cat.name}", f, :menu_categories, {:parent => cat.id}, 'set_parent_category margin-l-15')
        _child_cats = MenuCategory.set_parent_category(cat.id)
        if _child_cats.present?
          concat (content_tag(:ul, :class => "margin-l-30") {
            load_menu_category_list(_child_cats, f)
          })
        end        
      })
    end
  end

  # def load_menu_product_category_list(categories)
  #   categories.each do |cat|
  #     concat (content_tag(:li, class: ["collection-item", "dismissable", "padding-r-none", "padding-t-b-1"], :style => "-webkit-user-drag: none;") {
  #       # concat (label_tag(cat.id, cat.name))
  #       concat (radio_button_tag "menu_category", cat.id, {:class=> "with_gap", :id => "#{cat.name}_#{cat.id}"})
  #       concat (label_tag("menu_category_#{cat.id}", cat.name, :class=>"font-sz-12"))
  #       concat(content_tag(:div, '', :class => "float-r"){
  #         concat(content_tag(:a, '', :class => "m-btn green m-btn-small margin-r-5 plus", :id=> "#{cat.id}", :title => "Create child category under this category", "data-target" => "#new_category_modal", "data-toggle" => "modal"){
  #           concat(content_tag(:i, '', :class => "mdi-content-add"))
  #         })          
  #         concat(content_tag(:a, '', :href =>edit_menu_category_path(cat), :class => "m-btn orange m-btn-small margin-r-5"){
  #           concat(content_tag(:i, '', :class => "mdi-editor-border-color"))
  #         })        
  #       })        
  #       _child_cats = MenuCategory.set_parent_category(cat.id)
  #       if _child_cats.present?
  #         concat (content_tag(:ul, class: ["collection-child", "margin-t-none"]) {
  #           concat(content_tag(:br))
  #           load_menu_product_category_list(_child_cats)
  #         })
  #       end
  #     })  
  #   end  
  # end  

  def get_menu_product_mode_color(mode)  
    if mode == 1
      "light-blue light-blue-text text-lighten-5"
    elsif mode == 0
      "orange white-text"
    end
  end

  def  load_sections_dropdown(unit_id)
    _unit = Unit.find(unit_id)
    concat (content_tag(:li, class: ["collection-item", "dismissable", "padding-r-none"], :style => "-webkit-user-drag: none;") {
      concat(content_tag(:span, _unit.unit_name.humanize, :class => ""))
      concat(content_tag(:span, _unit.city, :class => "ultra-small secondary-content margin-r-10"))
      concat(content_tag(:span, _unit.unittype.unit_type_name.humanize, :class => "m-label teal"))
      concat(content_tag(:br))
      if _unit.sections.present?
        concat(content_tag(:h5, "Sections", :class => "margin-l-15 margin-t-none"))
        concat(content_tag(:ol, :class => "margin-l-30"){
          _unit.sections.each do |section|
            concat(content_tag(:li){
              concat (check_box_tag('section_id', section.id, false, :id => "section_#{section.id}", :class=>"units-checkbox" ))
              concat (label_tag("section_#{section.id}", section.name))
            })
          end
        })
      end
      _child_units = Unit.set_parent_unit(_unit.id)
      if _child_units.present?
        # concat (content_tag(:li, class: ["divider"]){})
        concat (content_tag(:ul, class: ["collection-child"]) {
          concat(content_tag(:br))
          _child_units.each do |unit|
            load_sections_dropdown(unit.id)    
          end
        })     
      end
    })
  end  

  def get_catalog_color mode
    if mode == 1
      "green"
    elsif mode ==0
      "orange"
    else
      "grey"
    end    
  end

end
