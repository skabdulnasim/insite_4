module InventoryReportsHelper
  def render_store_checkboxes(stores,prefix)
    if stores.present?
      concat (content_tag(:h6, 'Select stores', :class => 'grey-text'))
      stores.each do |store|
        if store.store_priority == "primary_store"
          concat (check_box_tag("#{prefix}_store[]", store.id, true, :id => "#{prefix}_store_#{store.id}", :class=>"filled-in" ))
          concat (label_tag("#{prefix}_store_#{store.id}", store.name, :class=>"margin-t-2"))
        end
      end
    else
      concat (content_tag(:h6, 'No store available', :class => 'red-text'))
    end
  end

  def render_all_store_checkboxes(stores,prefix)
    if stores.present?
      concat (content_tag(:h6, 'Select stores', :class => 'grey-text'))
      stores.each do |store|
        concat (check_box_tag("#{prefix}_store[]", store.id, true, :id => "#{prefix}_store_#{store.id}", :class=>"filled-in" ))
        concat (label_tag("#{prefix}_store_#{store.id}", store.name, :class=>"margin-t-2"))
      end
    else
      concat (content_tag(:h6, 'No store available', :class => 'red-text'))
    end
  end

  def render_all_store_checkboxes_notification(stores,prefix)
    if stores.present?
      concat (content_tag(:h6, 'Select stores', :class => 'grey-text'))
      stores.each do |store|
        concat (check_box_tag("#{prefix}_store[]", store.id, false, :id => "#{prefix}_store_#{store.id}", :class=>"filled-in" ))
        concat (label_tag("#{prefix}_store_#{store.id}", store.name, :class=>"margin-t-2"))
      end
    else
      concat (content_tag(:h6, 'No store available', :class => 'red-text'))
    end
  end

  def get_by_date_stock_summary_preferences(unit_id,key)
    _columns_array = ["product","opening_stock","stock_on_aduit","consumed_for_audit","audit_cost","consumed_for_order","order_cost","consumed_for_transfer","transfer_cost","total_debit","debit_cost","stock_purchase","purchase_cost","total_credit","credit_cost","closing_stock","current_stock","stock_value"]
    get_preference_checkboxes(unit_id,key,_columns_array)
  end

  def get_unit_wise_stock_summary_preferences(unit_id,key)
    _columns_array = ["opening_stock_value","total_credit_value","total_transfer_credit_value","total_purchase_credit_value","total_cost_of_transfer","closing_stock_value","total_sale"]
    get_preference_checkboxes(unit_id,key,_columns_array)
  end 

  def units_checkbox(unit_id,prefix,check_class="")
    _unit = Unit.find(unit_id)
    concat (content_tag(:li, class: ["collection-item", "dismissable", "padding-r-none"], :style => "-webkit-user-drag: none;") {
      concat (check_box_tag('unit_ids[]', _unit.id, true, :id => "#{prefix}_#{_unit.id}", :class=>"units-checkbox #{check_class}" ))
      concat (label_tag("#{prefix}_#{_unit.id}", _unit.unit_name))
      concat(content_tag(:span, _unit.unittype.unit_type_name.humanize, :class => "m-label teal"))
      _child_units = Unit.set_parent_unit(_unit.id).order("unit_name asc")
      if _child_units.present?
        concat (content_tag(:ul, class: ["collection-child"]) {
          concat(content_tag(:br))
          _child_units.each do |unit|
            units_checkbox(unit.id,prefix,check_class)   
          end
        })     
      end
    })
  end

  def units_checkbox_with_name(unit_id,prefix,checkbox_array_name,check_class="")
    _unit = Unit.find(unit_id)
    concat (content_tag(:li, class: ["collection-item", "dismissable", "padding-r-none"], :style => "-webkit-user-drag: none;") {
      concat (check_box_tag("#{checkbox_array_name}", _unit.id, true, :id => "#{prefix}_#{_unit.id}", :class=>"units-checkbox #{check_class}" ))
      concat (label_tag("#{prefix}_#{_unit.id}", _unit.unit_name))
      concat(content_tag(:span, _unit.unittype.unit_type_name.humanize, :class => "m-label teal"))
      _child_units = Unit.set_parent_unit(_unit.id).order("unit_name asc")
      if _child_units.present?
        concat (content_tag(:ul, class: ["collection-child"]) {
          concat(content_tag(:br))
          _child_units.each do |unit|
            units_checkbox_with_name(unit.id,prefix,checkbox_array_name,check_class)   
          end
        })     
      end
    })
  end

  def get_product_data(store, product, from_date, to_date)
    _arr = Stock.get_stock_data(store, product, from_date, to_date)
  end

  def get_product_total_staock(product_id)
    unit_ids = []
    store_ids = []
    unit_ids << current_user.unit.id
    current_user.unit.children.map { |e| unit_ids.push e.id } if current_user.unit.children.present?
    _stores = Store.set_unit_in(unit_ids).not_return
    _stores.map { |e| store_ids.push e.id  }
    _stock = Stock.product_total_stock(product_id,store_ids)

  end  

  def get_store_product_data(product_id,store_id)
    _stock = Stock.product_stock_in_store(product_id,store_id)
  end

  def units_checkboxs(unit_id)
    _unit = Unit.find(unit_id)
    concat (content_tag(:li, class: ["padding-r-none"], :style => "-webkit-user-drag: none;") {
      concat (check_box_tag('units_ids[]', _unit.id, false, :id => "#{_unit.id}", :class => "in-hand"))
      concat (label_tag("#{_unit.id}", _unit.unit_name)) 
      concat(content_tag(:span, _unit.unittype.unit_type_name.humanize, :class => "m-label teal"))
      concat(content_tag(:br))
      _child_units = Unit.set_parent_unit(_unit.id).order("unit_name asc")
      if _child_units.present?
        concat (content_tag(:ol) {
          _child_units.each do |unit|
            concat (check_box_tag('units_ids[]', unit.id, false, :id => "#{unit.id}", :class => "in-hand"))
            concat (label_tag("#{unit.id}", unit.unit_name))  
            concat(content_tag(:span, unit.unittype.unit_type_name.humanize, :class => "m-label teal"))
            concat(content_tag(:br))  
          end
        })     
      end
    })
  end  
  def  basic_unit_name(basic_unit_id)
    ProductUnit.select(:name).where("product_basic_unit_id=?",basic_unit_id).first
  end
  def units_checkboxss(unit_id,prefix)
    _unit = Unit.find(unit_id)
    concat (content_tag(:li, class: ["padding-r-none"], :style => "-webkit-user-drag: none;") {
      concat (check_box_tag('units_idss[]', _unit.id, false, :id => "#{prefix}_#{_unit.id}", :class => "in-store"))
      concat (label_tag("#{prefix}_#{_unit.id}", _unit.unit_name)) 
      concat(content_tag(:span, _unit.unittype.unit_type_name.humanize, :class => "m-label teal"))
      concat(content_tag(:br))
      _child_units = Unit.set_parent_unit(_unit.id).order("unit_name asc")
      if _child_units.present?
        concat (content_tag(:ol) {
          _child_units.each do |unit|
            concat (check_box_tag('units_idss[]', unit.id, false, :id => "#{prefix}_#{unit.id}", :class => "in-store"))
            concat (label_tag("#{prefix}_#{unit.id}", unit.unit_name))  
            concat(content_tag(:span, unit.unittype.unit_type_name.humanize, :class => "m-label teal"))
            concat(content_tag(:br))  
          end
        })     
      end
    })
  end  

  def get_availabe_stock(product_id,end_duration,start_duration=0)
    today = Date.parse(DateTime.now.strftime("%d-%m-%y"))
    from_date = today - start_duration.months
    to_date = today - end_duration.months
    
    
    aging_stock_count = 0
    if start_duration == 0
      aging_stock = Stock.where("created_at<=?",to_date)
    else
      aging_stock = Stock.by_date_range(from_date,to_date)
    end
    if aging_stock.present?
      aging_stock_count = aging_stock.get_product(product_id).available.sum(:available_stock)
    end
    return aging_stock_count
  end
end
