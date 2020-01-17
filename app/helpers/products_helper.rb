module ProductsHelper
  def get_product_composition_if_exist(product)
    _raw_products = @product.product_meta.set_type("raw")
    if _raw_products.present? 
      _raw_products = JSON.parse(_raw_products.first.meta_value)
      _raw_products.each do |rp|  
        concat(content_tag(:tr, class: ["data-table__selectable-row"], id: ["cart_item_#{@product.id}"]) {
          _product = Product.find(rp['raw_product_id'])
          concat(content_tag(:td, rp['raw_product_id'], class: ["col-lg-1"]){
            concat(check_box_tag("checked_raw[]", rp['raw_product_id'], true, {:id=>"check_#{rp['raw_product_id']}", :class=>"check check_input", "data-input-id"=>"#{rp['raw_product_id']}"}))
            concat(label_tag "check_#{rp['raw_product_id']}",'')
          })
          concat(content_tag(:td, _product.name, class: ["col-lg-4"]))
          concat(content_tag(:td, class: ["col-lg-3"]){
            concat(text_field_tag("quantity#{rp['raw_product_id']}",rp['raw_product_quantity'], {:class=>"form-control allow-numeric-only",:id=>"InputAmount_quantity#{rp['raw_product_id']}",:placeholder=>"Quantity",:step=>"any"}))
          })
          concat(content_tag(:td, class: ["col-lg-4"]){
            concat(select_tag "product_unit#{['raw_product_id']}", options_from_collection_for_select(@product_units, "id", "name", rp['raw_product_unit']), {:class=>"form-control",:id=>"product_unit#{rp['raw_product_id']}",:name=>"product_unit#{rp['raw_product_id']}"})
          })
        })
      end
    else  
      concat(content_tag(:tr, class: ["data-table__selectable-row no-item-selected"]) {
        content_tag(:td, "No raw products or composition products selected yet ", class: ["alert alert-warning"])
      })
    end    
  end  
end
