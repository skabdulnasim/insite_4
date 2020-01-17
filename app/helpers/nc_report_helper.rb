module NcReportHelper

  def get_by_date_nc_preferences(unit_id,key)
    _columns_array = ["bill_id","bill_serial","deliverables_at","order_source","status","user","remarks","date","procurement_cost","sales_price"]
    get_preference_checkboxes(unit_id,key,_columns_array)
  end

  def get_by_date_range_nc_preferences(unit_id,key)
    _columns_array = ["date","total_billed_amount","total_discount","total_nc","total_void","total_unpaid_amount","total_settled_amount","cash","card","total_tax","procurement_cost","sales_cost"]
    Bill.report_attributes.each do |key, attributes|
      if key == "tax"
        attributes.each do |attribute|
          _columns_array.push(attribute.parameterize)
        end          
      end            
    end
    get_preference_checkboxes(unit_id,key,_columns_array)
  end

  def get_category_wise_nc_preferences(unit_id,key)
    _columns_array = ["main_category","sub_category","product","quantity","procurement_cost","total_procurement_cost","sales_cost","total_sales_cost"]
    get_preference_checkboxes(unit_id,key,_columns_array)
  end

  def get_table_wise_nc_preferences(unit_id,key)
    _columns_array = ["date","table","remarks","bill","order_id","name","quantity","sales_cost","total_sales_cost","time","user","procurement_cost","total_procurement_cost"]
    get_preference_checkboxes(unit_id,key,_columns_array)
  end  

end
