module UnitsHelper

  def setup_unit(unit)
    unit.stores.present? ? unit.stores : 1.times {unit.stores.build(:name => "Default Store")}
    unit.sections.present? ? unit.sections : 1.times {unit.sections.build(:name => "Default Section")}
    unit.sorts.present? ? unit.sorts : 1.times {unit.sorts.build(:name => "Default SORT")}
    unit
  end

  def unit_details
    current_unit = Unit.find(current_user.unit_id)
    if current_unit.unit_detail.present?
      return current_unit.unit_detail.options
    else
      return 0
    end
  end

  def add_new_unit_type
    html = ""
    html = content_tag :span, "Note: ", :class => "font-sz-11", :style => "font-weight : bold;"
    if @unit.present?
      html += content_tag :span, "Not in the list? ", :class => "font-sz-11"
    else
      html += content_tag :span, "No unit types are currently available, ", :class => "font-sz-11"
    end
    html += link_to("Click here to add new.", new_unit_path, class: "font-sz-11")
  end
  
  def load_units_tree(unit_id)
    _unit = Unit.find(unit_id)
    concat (content_tag(:li, class: ["collection-item", "dismissable", "padding-r-none"], :style => "-webkit-user-drag: none;") {
      check_status = (current_user.unit_id != unit_id) ? false : true
      # Showing unit type
      concat(content_tag(:div, class: ["col-lg-8 padding-l-r-none"]){
        concat(content_tag(:div, class: ["col-lg-2 padding-l-r-none"]){
          concat(content_tag(:span, _unit.unittype.unit_type_name.humanize, :class => "m-label teal margin-l-none margin-r-5"))
        })
        # Showing unit name and address
        concat(content_tag(:div, class: ["col-lg-10 padding-l-r-none"]){
          concat (label_tag(_unit.id, _unit.unit_name))
          concat (content_tag(:p, class: ["margin-t-b-0"]){
            concat(content_tag(:span, "Address: #{_unit.address}", :class => "font-sz-11"))
          })        
        })
      })
      # Showing unit actions
      concat(content_tag(:div, class: ["col-lg-12 padding-l-r-none"]){
        concat(content_tag(:div, '', :class => "float-r"){
          if 'owner' == current_user.unit.unittype.unit_type_name.downcase || 'superadmin' == current_user.unit.unittype.unit_type_name.downcase
            if 'outlet' == _unit.unittype.unit_type_name.downcase || 'node' == _unit.unittype.unit_type_name.downcase
              # if AppConfiguration.get_config_value('third_party_urbanpiper') == "enabled" || AppConfiguration.get_config_value('third_party_zomato') == "enabled"
              concat (check_box_tag('thirdparty_unit_id[]', "#{_unit.id}", false, :id => "thirdparty_unit_id_#{_unit.id}" ))          
              concat (label_tag("thirdparty_unit_id_#{_unit.id}","")) 
              # if AppConfiguration.get_config_value('third_party_urbanpiper') == "enabled"
              #   concat(content_tag(:span, '',:class=> "plus",:onclick => "toggle_unit_id(#{_unit.id})", "data-target" => "#thirdparty_unit_toggle", "data-toggle" => "modal"){
              #     concat(content_tag(:a, '',:class => "m-btn green waves-effect waves-light m-btn-small margin-r-5"){
              #       concat(content_tag(:span, "Toggle To Urbanpiper", :class => "font-sz-11"))
              #     }) 
              #   })
              # end
              # end
            end
          end
          # if 'outlet' == _unit.unittype.unit_type_name.downcase || 'node' == _unit.unittype.unit_type_name.downcase
          #   # concat(content_tag(:span, '',:class=> "plus click_effect_to_add_unit_id", "data-unit-id" => "#{_unit.id}", "data-target" => "#thirdparty_unit_upload", "data-toggle" => "modal"){
          #   #   concat(content_tag(:a, '',:class => "m-btn green waves-effect waves-light m-btn-small margin-r-5"){
          #   #     concat(content_tag(:span, "Upload To Thirdparty", :class => "font-sz-11"))
          #   #   }) 
          #   # })
          #   concat(content_tag(:span, '',:class=> "plus click_effect_to_add_toggle_unit_id", "data-unit-id" => "#{_unit.id}", "data-target" => "#thirdparty_unit_toggle", "data-toggle" => "modal"){
          #     concat(content_tag(:a, '',:class => "m-btn green waves-effect waves-light m-btn-small margin-r-5"){
          #       concat(content_tag(:span, "Toggle To Urbanpiper", :class => "font-sz-11"))
          #     }) 
          #   })
          # end
          concat(content_tag(:a, '', :href =>unit_path(_unit), :class => "m-btn green waves-effect waves-light m-btn-small margin-r-5"){
            concat(content_tag(:i, '', :class => "mdi-content-add"))
          })          
          concat(content_tag(:a, '', :href =>edit_unit_path(_unit), :class => "m-btn orange waves-effect waves-light m-btn-small margin-r-5"){
            concat(content_tag(:i, '', :class => "mdi-editor-border-color"))
          })
          # concat(content_tag(:a, '', :href =>unit_path(_unit), :class => "m-btn red waves-effect waves-light m-btn-small margin-r-5", :method => :delete, :data => { :confirm => t('.confirm', :default => t("helpers.links.confirm", :default => 'Are you sure?')) }){
          #   concat(content_tag(:i, '', :class => "mdi-action-delete"))
          # })        
        })   
      })
      concat(content_tag(:div, class: ["clearfix"]){})
      #Recursive call to get the child units
      _child_units = Unit.set_parent_unit(_unit.id)
      if _child_units.present?
        concat (content_tag(:ul, class: ["collection-child"]) {
          concat(content_tag(:br))
          _child_units.each do |unit|
            load_units_tree(unit.id)    
          end
        })     
      end
    })
  end
end
