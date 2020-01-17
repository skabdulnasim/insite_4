class NcReportController < ApplicationController
  layout "material"
  
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  before_filter :set_module_details
  before_filter :set_timerange, only: [:by_date, :by_date_range, :category_wise]

  def index
    _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @menu_cards = MenuCard.set_mode(1).set_unit(_unit_id).not_trashed
     _units = Bill.select("DISTINCT(unit_id)")
    @units = Unit.order(unit_name: :asc).get_unit_name(_units)
    respond_to do |format|
      format.html
      format.json { render json: @menu_cards }
    end
  end

  def by_date
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @unit = Unit.find(@unit_id)
    @sales = Bill.unit_bills(@unit_id).order("id asc").nc_bill
    @sales = @sales.by_recorded_at(@from_datetime,@to_datetime) if params[:from_date].present?
    @sales = @sales.check_bill_status(params[:status]) if params[:status].present?
    smart_listing_create :sales_by_date, @sales, partial: "nc_report/sales_by_date_smartlist",default_sort: {recorded_at: "asc"}
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.csv { send_data Bill.invalid_bill.by_date_nc_to_csv(current_user.unit_id,@unit_id,@sales,@from_datetime,@to_datetime), filename: "nc-report-of-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end
  end

  def by_date_range
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @unit = Unit.find(@unit_id)
    @sales = Bill.select("date(recorded_at) as date, sum(grand_total) as total_sale, sum(tax_amount) as total_tax, sum(discount) as total_discount").group("date(recorded_at)").unit_bills(@unit_id).order("date(recorded_at)").by_recorded_at(@from_datetime,@to_datetime).valid_bill
    @unit_detail_options = @unit.unit_detail.options if current_user.present? && @unit.unit_detail.present?
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.csv { send_data Bill.sales_summary_to_csv(@unit_id,@sales,@from_datetime,@to_datetime), filename: "nc-summary-report-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end
  end

  def category_wise
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @unit = Unit.find(@unit_id)
    @preferences = ReportPreference.by_unit(current_user.unit_id).by_key('nc_report_category_wise').first
    @pref = @preferences.present? ? JSON.parse(@preferences.allowed_attributes) : ["main_category","sub_category","product","quantity","procurement_cost","total_procurement_cost","sales_cost","total_sales_cost"]
    @unit_detail_options = @unit.unit_detail.options if current_user.present? && @unit.unit_detail.present?
    menu_card = MenuCard.find(params[:menu_card])
    @categories = menu_card.menu_categories.where(:parent => nil)
    @category_sales = {}
    _from_datetime = params[:from_date].to_date.beginning_of_day+@unit_detail_options[:day_closing_time].to_i.hours if @unit.unit_detail.present?
    _from_datetime ||= params[:to_date].to_date.beginning_of_day
    _to_datetime = params[:to_date].to_date.end_of_day+@unit_detail_options[:day_closing_time].to_i.hours if @unit.unit_detail.present?
    _to_datetime ||= params[:to_date].to_date.end_of_day
    order_id_for_bill = Bill.by_recorded_at(_from_datetime,_to_datetime).nc_bill.map{|bill| bill.orders.map{|order| order.id}}.flatten
    if params[:category_id].present?
      data = menu_card.menu_categories.where('id =?', params[:category_id]).first
      sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.submenucategories.map{|category| category.menu_products.map{|product| product.id}}.flatten).sum("unit_price_without_tax * quantity")
      if @category_sales.has_key? data.name
        @category_sales[data.name]["sale"] = @category_sales[data.name]["sale"].to_f+sale.to_f
      else
        @category_sales[data.name] = {'name'=>data.name,'sale'=>sale,'children' => []}
      end
      procured_cost = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.submenucategories.map{|category| category.menu_products.map{|product| product.id}}.flatten).sum("procurement_cost * quantity")
      if @category_sales.has_key? data.name
        @category_sales[data.name]["procured_cost"] = @category_sales[data.name]["procured_cost"].to_f+procured_cost.to_f
      else
        @category_sales[data.name] = {'name'=>data.name,'procured_cost'=>sale,'children' => []}
      end
      data.submenucategories.each do |subcategory|
        sub_sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).sum("unit_price_without_tax * quantity")
        sub_procured_cost = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).sum("procurement_cost * quantity")
        next if sub_sale.to_i ==0
        product_sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).group("product_name,unit_price_without_tax,procurement_cost").select("product_name,unit_price_without_tax,procurement_cost,SUM((procurement_cost+customization_price) * quantity) as total_procurement_cost, SUM(unit_price_without_tax * quantity) as total_sales,SUM(quantity) as quantity").order('product_name')
        tmp = {}
        tmp[subcategory.name]={'name'=>subcategory.name,'sale'=> sub_sale,'sub_procured_cost'=> sub_procured_cost,'products'=> product_sale}
        @category_sales[data.name]['children'] << tmp
      end
    else
      menu_card.menu_categories.where(:parent => nil).each do |data|
        sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.submenucategories.map{|category| category.menu_products.map{|product| product.id}}.flatten).sum("unit_price_without_tax * quantity")
        next if sale.to_i == 0
        if @category_sales.has_key? data.name
          @category_sales[data.name]["sale"] = @category_sales[data.name]["sale"].to_f+sale.to_f
        else
          @category_sales[data.name] = {'sale'=>sale,'children' => []}
        end
        procured_cost = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.submenucategories.map{|category| category.menu_products.map{|product| product.id}}.flatten).sum("procurement_cost * quantity")
        next if procured_cost.to_i == 0
        if @category_sales.has_key? data.name
          @category_sales[data.name]["procured_cost"] = @category_sales[data.name]["procured_cost"].to_f+procured_cost.to_f
        else
          @category_sales[data.name] = {'procured_cost'=>sale,'children' => []}
        end
        data.submenucategories.each do |subcategory|
          sub_sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).sum("unit_price_without_tax * quantity")          
          sub_procured_cost = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).sum("procurement_cost * quantity")
          next if sub_sale.to_i ==0
          product_sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).group("product_name,unit_price_without_tax,procurement_cost").select("product_name,unit_price_without_tax,procurement_cost,SUM((procurement_cost+customization_price) * quantity) as total_procurement_cost, SUM(unit_price_without_tax * quantity) as total_sales,SUM(quantity) as quantity").order('product_name')
          tmp = {}
          tmp[subcategory.name]={'sale'=> sub_sale,'sub_procured_cost'=> sub_procured_cost,'products'=> product_sale}
          @category_sales[data.name]['children'] << tmp
        end
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json {render json: category_array}
      format.csv { send_data category_sales_to_csv(@category_sales), filename: "categor-nc-#{menu_card.name}-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end

  end

  def table_wise
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @unit = Unit.find(@unit_id)
    @preferences = ReportPreference.by_unit(current_user.unit_id).by_key('nc_report_table_wise').first
    @unit_detail_options = @unit.unit_detail.options if current_user.present? && @unit.unit_detail.present?
    #menu_card = MenuCard.find(params[:menu_card])
    @table_wise = {}
    (params[:from_date].to_date..params[:to_date].to_date).each do |date_string|
      if date_string.to_date < "2016-04-01".to_date
        date_string = "2016-04-01"
      end 
      _from_datetime = date_string.to_date.beginning_of_day+@unit_detail_options[:day_closing_time].to_i.hours if @unit.unit_detail.present?
      _from_datetime ||= date_string.to_date.beginning_of_day
      _to_datetime = date_string.to_date.end_of_day+@unit_detail_options[:day_closing_time].to_i.hours if @unit.unit_detail.present?
      _to_datetime ||= date_string.to_date.end_of_day
      @table_wise[date_string] = {}
      @table_wise[date_string][:details]={}
      @table_wise[date_string][:day_total]=0
      @table_wise[date_string][:day_total_sales]=0      
      bills = Bill.by_recorded_at(_from_datetime,_to_datetime).nc_bill
      bills.each do |bill|
        _orders = bill.orders
        _order_row = {}
        _orders.each do |order|
          _order_row[order.id]= order.order_details.where(:trash=>0).map{|order_detail| {:name=> order_detail.product_name,
                                                                        :quantity=>order_detail.quantity,
                                                                        :procurement_cost=>order_detail.procurement_cost,
                                                                        :total_cost=>order_detail.quantity*order_detail.procurement_cost,
                                                                        :sales_cost=>order_detail.unit_price_without_tax,
                                                                        :total_sales_cost=>order_detail.quantity*order_detail.unit_price_without_tax}}
        end
        unless @table_wise[date_string][:details].has_key? bill.deliverable.name
          @table_wise[date_string][:details][bill.deliverable.name] = {}
          @table_wise[date_string][:details][bill.deliverable.name][:bills] = {}
          @table_wise[date_string][:details][bill.deliverable.name][:table_total] = 0
          @table_wise[date_string][:details][bill.deliverable.name][:table_total_sales] = 0          
        end
        bill_sales_total = bill.orders.inject(0){|result,order| result + order.order_details.where(:trash=>0).inject(0){|data,o_d| data+(o_d.unit_price_without_tax*o_d.quantity)}}
        bill_total = bill.orders.inject(0){|result,order| result + order.order_details.where(:trash=>0).inject(0){|data,o_d| data+(o_d.procurement_cost*o_d.quantity)}}
        @table_wise[date_string][:details][bill.deliverable.name][:bills][bill.id] = {:remarks=>bill.remarks,
                                                                      :orders=>_order_row,
                                                                      :time=>bill.recorded_at.strftime('%r'),
                                                                      :user=>bill.biller.profile.firstname,
                                                                      :total_cost=> bill_total,
                                                                      :total_sales=> bill_sales_total}
        @table_wise[date_string][:details][bill.deliverable.name][:table_total] = @table_wise[date_string][:details][bill.deliverable.name][:table_total] + bill_total
        @table_wise[date_string][:details][bill.deliverable.name][:table_total_sales] = @table_wise[date_string][:details][bill.deliverable.name][:table_total_sales] + bill_sales_total
        @table_wise[date_string][:day_total]= @table_wise[date_string][:day_total] + bill_total
        @table_wise[date_string][:day_total_sales]= @table_wise[date_string][:day_total_sales] + bill_sales_total
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.csv { send_data table_wise_nc_sales_to_csv(@table_wise), filename: "detail-nc-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end
  end

  def save_report_preferences
    _preference = ReportPreference.by_unit(current_user.unit_id).by_key(params[:report_key]).first
    _attributes =  JSON.generate(params[:columns])
    if _preference.present?
      _preference.update_attributes(:allowed_attributes => _attributes)
    else
      ReportPreference.create(:report_key => params[:report_key], :allowed_attributes => _attributes, :unit_id => current_user.unit_id)
    end
    
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Preferences successfully updated.' }
    end    
  end

  private

  def set_module_details
    @module_id = "reports"
    @module_title = "NC Report"
  end  

  def category_sales_to_csv(data)
    CSV.generate do |csv|
      preferences = ReportPreference.by_unit(current_user.unit_id).by_key('nc_report_category_wise').first
      _pref = preferences.present? ? JSON.parse(preferences.allowed_attributes) : [ "Main Category","Sub Category",'Product','Quantity',"Procurement Cost(per unit)","Total Procurement Cost","Sales Cost(per unit)","Total Sales Cost"]
      csv << _pref
      @category_sales.each do |main_cat,data|
        _row = Array.new
        _row.push(main_cat) if _pref.include?('main_category')
        _row.push('') if _pref.include?('sub_category')
        _row.push('') if _pref.include?('product')
        _row.push('') if _pref.include?('quantity')
        _row.push('') if _pref.include?('cost')
        _row.push(data['sale']) if _pref.include?('total_cost')
        _row.push('') if _pref.include?('procurement_cost')
        _row.push(data['procured_cost']) if _pref.include?('total_procurement_cost')
        _row.push('') if _pref.include?('sales_cost')
        _row.push(data['sale']) if _pref.include?('total_sales_cost')
        csv << _row
        data["children"].each do |sub_cat_data|
          _row = Array.new
          _row.push('') if _pref.include?('main_category')
          _row.push(sub_cat_data.keys.first) if _pref.include?('sub_category')
          _row.push('') if _pref.include?('product')
          _row.push('') if _pref.include?('quantity')
          _row.push('') if _pref.include?('cost')
          _row.push(sub_cat_data[sub_cat_data.keys.first]["sale"]) if _pref.include?('total_cost')
          _row.push('') if _pref.include?('procurement_cost')
          _row.push(sub_cat_data[sub_cat_data.keys.first]["sub_procured_cost"]) if _pref.include?('total_procurement_cost')
          _row.push('') if _pref.include?('sales_cost')
          _row.push(sub_cat_data[sub_cat_data.keys.first]["sale"]) if _pref.include?('total_sales_cost')
          csv << _row          
          sub_cat_data[sub_cat_data.keys.first]["products"].each do |product|
            _row = Array.new
            _row.push('') if _pref.include?('main_category')
            _row.push('') if _pref.include?('sub_category')
            _row.push(product[:product_name]) if _pref.include?('product')
            _row.push(product[:quantity]) if _pref.include?('quantity')
            _row.push(product[:procurement_cost]) if _pref.include?('cost')
            _row.push(product[:total_sales]) if _pref.include?('total_cost')
            _row.push(product[:procurement_cost]) if _pref.include?('procurement_cost')
            _row.push(product[:total_procurement_cost]) if _pref.include?('total_procurement_cost')            
            _row.push(product[:unit_price_without_tax]) if _pref.include?('sales_cost')
            _row.push(product[:total_sales]) if _pref.include?('total_sales_cost')
            csv << _row
          end
        end
        
      end
    end
  end

  def table_wise_nc_sales_to_csv(data)
    CSV.generate do |csv|
      csv << [ 'Date', 'Table', 'Remarks', 'Bill', 'Order ID', 'Name', 'Quantity', 'Sales Price', 'Total Sales Price', 'Time', 'User', 'Procurement Cost', 'Total Procurement Cost']
      total_cost_till_date = 0
      total_sales_cost_till_date = 0
      @table_wise.each do |date,table_summery|
        csv << [date,'','','','','','','','','','']
        table_summery[:details].each do |table, bill_summery|
          csv <<['',table,'','','','','','','','','']
          bill_summery[:bills].each do |bill_id,data|
            csv <<['','',data[:remarks],bill_id,'','','','','',data[:time],data[:user]]
            data[:orders].each do |order_id,order_items|
              order_items.each do |item|
                csv <<['','','','',order_id,item[:name],item[:quantity],item[:sales_cost],item[:total_sales_cost],'','',item[:procurement_cost],item[:total_cost]]
              end
            end
            csv <<['','','','','',' Total NC on Bill','','',data[:total_sales],'','','',data[:total_cost]]
          end
          csv <<['','','','','','Total NC on Table','','',bill_summery[:table_total_sales],'','','',bill_summery[:table_total]]
        end
        csv <<['','','','','','Total NC of Day','','',table_summery[:day_total_sales],'','','',table_summery[:day_total]]
        total_sales_cost_till_date =total_sales_cost_till_date+table_summery[:day_total_sales]
        total_cost_till_date =total_cost_till_date+table_summery[:day_total]
      end
      csv <<['','','','','','Total NC Till Date','','',total_sales_cost_till_date,'','','',total_cost_till_date]
    end
  end
end