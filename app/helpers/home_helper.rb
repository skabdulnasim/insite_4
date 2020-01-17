module HomeHelper

  def  load_units_dropdown(unit_id)
    _unit = Unit.find(unit_id)
    concat (content_tag(:li, class: ["collection-item", "dismissable", "padding-r-none"], :style => "-webkit-user-drag: none;") {
      # concat(content_tag(:span, "--- "))
      #check_status = (current_user.unit_id != unit_id) ? false : true
      if current_user.role.name == "owner" 
        check_status = true
      else
        check_status = (current_user.unit_id != unit_id) ? false : true
      end 
      if _unit.unittype.unit_type_name.humanize == "Outlet"
        check_box_class = 'checkbox-outlet'         
      elsif _unit.unittype.unit_type_name.humanize == "Owner"
        check_box_class = 'check'
      else
        check_box_class = 'checkbox-dc'
      end 
      concat (check_box_tag('unit_id', _unit.id, check_status, :id => "#{_unit.id}", :class=>"units-checkbox #{check_box_class}" ))
      concat (label_tag(_unit.id, _unit.unit_name))
      concat(content_tag(:span, _unit.city, :class => "ultra-small secondary-content margin-r-10"))
      concat(content_tag(:span, _unit.unittype.unit_type_name.humanize, :class => "m-label teal"))
      _child_units = Unit.set_parent_unit(_unit.id)
      if _child_units.present?
        # concat (content_tag(:li, class: ["divider"]){})
        concat (content_tag(:ul, class: ["collection-child"]) {
          concat(content_tag(:br))
          _child_units.each do |unit|
            p unit
            load_units_dropdown(unit.id)    
          end
        })     
      end
    })
  end

  def  load_section_selector(unit_id)
    _unit = Unit.find(unit_id)
    concat (content_tag(:li, class: ["collection-item", "dismissable", "padding-r-none"], :style => "-webkit-user-drag: none;") {
      concat(content_tag(:span, _unit.unittype.unit_type_name.humanize, :class => "m-label teal margin-l-none"))
      concat (content_tag(:span, _unit.unit_name, :class => "margin-l-5 font-bold"))
      # concat(content_tag(:span, "#{_unit.landmark}", :class => "grey-text margin-l-15 font-13"))
      concat(content_tag(:span, _unit.city, :class => "ultra-small secondary-content margin-r-10"))
      if _unit.sections.present?
        concat(content_tag(:h6, I18n.t(:title_sections), :class => "margin-l-15 grey-text text-darken-2"))
        _unit.sections.each do |section|
          concat(content_tag(:h6, :class => "margin-t-b-0 margin-l-30"){
            concat (radio_button_tag('section_id', section.id, false, :id => "section_#{section.id}", :class=>"section_selector with-gap", "data-section-id"=>section.id, "data-unit-id"=>_unit.id ))
            concat (label_tag("section_#{section.id}", section.name, :class=>"font-13"))          
          })
        end
      end
      _child_units = Unit.set_parent_unit(_unit.id)
      if _child_units.present?
        concat (content_tag(:ul, class: ["collection-child"]) {
          concat(content_tag(:br))
          _child_units.each do |unit|
            load_section_selector(unit.id)    
          end
        })     
      end
    })
  end

  def load_section_selector_owner(unit_id)
    _current_unit = unit_id
    menu_scope = MenuCard.set_unit(_current_unit).not_trashed
    menu_scope = menu_scope.set_scope(params[:scope]) if params[:scope].present?
    menu_scope = menu_scope.set_mode(params[:mode]) if params[:mode].present?
    
    _unit = Unit.find(unit_id)
    concat (content_tag(:li, class: ["collection-item", "dismissable", "padding-r-none"], :style => "-webkit-user-drag: none;") {
      concat(content_tag(:div){
        concat(content_tag(:span, _unit.unittype.unit_type_name.humanize, :class => "m-label teal margin-l-none"))
        concat (content_tag(:span, _unit.unit_name, :class => "margin-l-5 font-bold"))
        concat(content_tag(:span, _unit.city, :class => "ultra-small secondary-content margin-r-10"))
      })
      if _unit.sections.present?
        unless menu_scope.empty?
          menu_scope.each do |object|
            concat (content_tag(:div, class: ["product-card col-lg-3 col-xs-12 col-sm-12 padding-5"]) {
              concat (content_tag(:div, class: ["card margin-t-b-0 waves-effect waves-light #{get_catalog_color(object.mode)}"]) {
                concat (content_tag(:div, class: ["card-content white-text height-200"]) {
                  concat (content_tag(:h4, class: ["sm-header margin-t-none text-lighten-5"]) {
                    concat (content_tag(:small,"##{object.id} ", :class=>"font-sz-11 white-text table-card-text-13"))
                    concat(content_tag(:a, object.name, :class=>"white-text", :href=>menu_card_path(object)))                   
                  })
                  concat (content_tag(:div,"#{I18n.t(:label_updated_at)} #{object.updated_at.strftime('%d %b %A %Y, %I:%M %p')}",:class=>" font-sz-12 white-text table-card-text-13"))
                  concat (content_tag(:h5, :class=>"white-text margin-b-2"){
                    concat ("#{I18n.t(:label_scope)}:")
                    concat (content_tag(:span,object.scope.humanize,:class=>"float-r"))
                  })
                  concat (content_tag(:h5, :class=>"white-text margin-b-2"){
                    concat ("#{I18n.t(:label_section)}:")
                    concat (content_tag(:span,object.section.name.humanize,:class=>"float-r"))
                  })
                  concat (content_tag(:h5, :class=>"white-text margin-b-2"){
                    concat ("#{I18n.t(:text_no_of_products)}:")
                    concat (content_tag(:span,object.menu_products.count,:class=>"float-r m-label white grey-text text-darken-3"))
                  })
                })
                concat (content_tag(:div,:class=>"card-action darken-1 white"){
                  concat (content_tag(:div, :class=>"col-sm-6 padding-l-r-none"){
                    menu_mode_status = (object.mode == 1) ? true : false
                    concat(content_tag(:div, :class=>"switch margin-l-5"){
                      concat(content_tag(:label){
                        concat (check_box_tag('menu_mode', object.id, 1,"data-id"=>"#{object.id}","data-mode-active"=>"1","data-mode-inactive"=>"0", "class"=> "update_menu_mode"))
                        concat(content_tag(:span,"",:class=>"lever margin-l-r-none")) 
                      })
                    })
                  })
                  concat(content_tag(:div, :class=>"col-sm-6 padding-l-r-none"){
                    concat(content_tag(:a, :class=>" m-btn m-btn-small white-text float-r #{get_catalog_color(object.mode)}", :href=>menu_card_path(object)){
                      concat(content_tag(:i,"",:class=>"mdi-action-visibility smaller left"))
                      concat(I18n.t(:label_view))
                    })
                  })
                  concat(content_tag(:div,"",:class=>"clearfix"))
                })
                
              })
            })
          end
          concat(content_tag(:div,"",:class=>"clearfix"))
        else
          concat(content_tag(:div, "No menu cards found", :class => "alert alert-warning"))
        end
      end
      _child_units = Unit.set_parent_unit(_unit.id)
      if _child_units.present?
        concat (content_tag(:ul, class: ["collection-child"]) {
          _child_units.each do |unit|
            load_section_selector_owner(unit.id)    
          end
        })     
      end
    })
  end
end
