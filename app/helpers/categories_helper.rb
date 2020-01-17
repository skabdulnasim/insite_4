module CategoriesHelper
  def  load_product_category_list(categories)
    categories.each do |cat|
      concat (content_tag(:li, class: ["collection-item", "dismissable", "padding-r-none"], :style => "-webkit-user-drag: none;") {
        concat (label_tag(cat.id, cat.name))
        concat(content_tag(:div, '', :class => "float-r"){
          concat(content_tag(:a, '', :class => "m-btn green m-btn-small margin-r-5 plus", :id=> "#{cat.id}~#{cat.name}", :title => "Create child category under this category", "data-target" => "#new_category_modal", "data-toggle" => "modal"){
            concat(content_tag(:i, '', :class => "mdi-content-add"))
          })          
          concat(content_tag(:a, '', :href =>edit_category_path(cat), :class => "m-btn orange m-btn-small margin-r-5"){
            concat(content_tag(:i, '', :class => "mdi-editor-border-color"))
          })
          concat(content_tag(:a, '', :href =>category_path(cat), :class => "m-btn red m-btn-small margin-r-5", :method => :delete, :data => { :confirm => t('.confirm', :default => t("helpers.links.confirm", :default => 'Are you sure?')) }){
            concat(content_tag(:i, '', :class => "mdi-action-delete"))
          })        
        })        
        _child_cats = Category.set_parent_category(cat.id)
        if _child_cats.present?
          concat (content_tag(:ul, class: ["collection-child"]) {
            concat(content_tag(:br))
            load_product_category_list(_child_cats)
          })
        end
      })  
    end  
  end
end
