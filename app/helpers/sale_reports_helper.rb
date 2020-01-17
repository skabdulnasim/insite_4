module SaleReportsHelper
  def get_settlement_data_by_date(unit_id,from_datetime,to_datetime)
    settlement_data = Bill.get_unit_settlement_data(unit_id,from_datetime,to_datetime)
  end  

  def add_on_sales(_unit_id,_section_id,from_datetime,to_datetime)
    orders = Order.by_unit_id(_unit_id).by_recorded_at(from_datetime,to_datetime).billed?.includes(order_details:[:order_detail_combinations])
    order_details_combination_ids = orders.map{|order| order.order_details.where(:section_id => _section_id).map{|order_details| order_details.order_detail_combinations.map{|order_detail_combinations| order_detail_combinations.id }}}.flatten
    order_details_combinations = OrderDetailCombination.where("id IN(?)",order_details_combination_ids).select("product_id,product_name,product_price,sum(combination_qty) as quantity,sum(total_price) as total_price").group(:product_id,:product_name,:product_price)
  end

  def get_by_date_sales_preferences(unit_id,key)
    _columns_array = ["bill_id","bill_serial","deliverables_at","order_source","bill_amount_without_tax","total_tax","discount","total","pax","roundoff","status","user","remarks","date","created_at","customer","section_name","third_party_order_id"]
    Bill.report_attributes.each do |key, attributes|
      if key == "payment"
        attributes.each do |attribute|
          _columns_array.push(attribute.parameterize)
        end  
      elsif key == "tax"
        attributes.each do |attribute|
          _columns_array.push(attribute.parameterize)
        end 
      elsif key == "third_party"
        attributes.each do |attribute|
          _columns_array.push(attribute.parameterize)
        end           
      end            
    end
    get_preference_checkboxes(unit_id,key,_columns_array)
  end

  def get_by_date_range_sales_preferences(unit_id,key)
    _columns_array = ["date","bill_no","bill_slno","total_billed_amount","total_discount","total_nc","total_void","total_unpaid_amount","total_settled_amount","cash","card","loyalty_card","third_party","total_tax"]
    Bill.report_attributes.each do |key, attributes|
      if key == "tax"
        attributes.each do |attribute|
          _columns_array.push(attribute.parameterize)
        end          
      end            
    end
    get_preference_checkboxes(unit_id,key,_columns_array)
  end 

  def get_by_date_category_sales_preferences(unit_id,key)
    _columns_array = ["main_cetegory","sub_cetegory","product","hsn_code","sgst_percentage","cgst_percentage","quantity","average_cost","total_cost","sale_price","sale_without_tax","sgst","cgst","gst","sku","tax","sale_with_tax","item_discount"]
    get_preference_checkboxes(unit_id,key,_columns_array)
  end 
  
  def get_by_time_interval_sales_preferences(unit_id,key)
    _columns_array = ["main_cetegory","sub_cetegory","product","quantity","average_cost","total_cost","sale_price","sale_without_tax"]
    get_preference_checkboxes(unit_id,key,_columns_array)
  end 

  def get_sale_summery_sales_preferences(unit_id,key)
    _columns_array = ["branch_name","grand_total","material_cost","percentage","unpaid_amt","settled_amt","cash","card","third_party","loyalty_card","discount"]
    get_preference_checkboxes(unit_id,key,_columns_array)
  end 

  def get_by_date_sku_sales_preferences(unit_id,key)
    _columns_array = ["bill_id","product_name","serial_no","sku","unit_price_without_tax","unit_price_with_tax","tax_amount","quantity","subtotal","status","payment_mode","name","phone_no","date"]
    get_preference_checkboxes(unit_id,key,_columns_array)    
  end

  def get_preference_checkboxes(unit_id,key,columns_array)
    preferences = ReportPreference.by_unit(unit_id).by_key(key).first
    @pref = preferences.present? ? JSON.parse(preferences.allowed_attributes) : Array.new    
    columns_array.each do |column|
      concat (check_box_tag("columns[]", column, @pref.include?(column), :id=>column))
      concat (label_tag(column, column.humanize))
      concat(content_tag(:br))
    end
  end

  def get_nc_void_data(unit_id,from_datetime,to_datetime)
    data = Bill.invalid_bill.unit_bills(unit_id).by_recorded_at(from_datetime,to_datetime).group(:status).sum(:bill_amount)
  end

  def get_meterial_cost(unit_id,from_datetime,to_datetime)
    material_cost = OrderDetail.set_unit(unit_id).by_date_range(from_datetime,to_datetime).sum("material_cost")
  end

  def  load_units_checkbox(unit_id)
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
        valid_unit = _unit.id         
      elsif _unit.unittype.unit_type_name.humanize == "Owner"
        check_box_class = 'check'
        valid_unit = ''
      else
        check_box_class = 'checkbox-dc'
        valid_unit = ''
      end 
      concat (check_box_tag('unit_id[]', valid_unit, check_status, :id => "#{_unit.id}", :class=>"units-checkbox #{check_box_class}" ))
      concat (label_tag(_unit.id, _unit.unit_name))
      concat(content_tag(:span, _unit.unittype.unit_type_name.humanize, :class => "m-label teal"))
      _child_units = Unit.set_parent_unit(_unit.id).order("unit_name asc")
      if _child_units.present?
        # concat (content_tag(:li, class: ["divider"]){})
        concat (content_tag(:ul, class: ["collection-child"]) {
          concat(content_tag(:br))
          _child_units.each do |unit|
            load_units_checkbox(unit.id)    
          end
        })     
      end
    })
  end

end