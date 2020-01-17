class SaleReportsController < ApplicationController
  layout "material"
  
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  include SaleReportsHelper

  before_filter :set_module_details
  before_filter :set_timerange, only: [:by_date, :by_date_range, :category_wise, :sku_wise, :sale_user_wise, :by_date_boh, :by_date_boh_customer_wise, :by_date_cod, :adons_sales_reports]


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

  def by_date_cod
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @report_type_cod = ''
    if params[:report_type_cod].present?
      @report_type_cod=params[:report_type_cod]
      if params[:report_type_cod]=="customer"
        @bills = Bill.unit_bills(@unit_id).valid_bill.cod_bill.by_recorded_at(@from_datetime,@to_datetime).bill_customer_group_cod
      elsif params[:report_type_cod]=="bill"
        @bills = Bill.unit_bills(@unit_id).valid_bill.cod_bill.by_recorded_at(@from_datetime,@to_datetime).order("recorded_at asc")
      end
    else
      @bills = Bill.unit_bills(@unit_id).valid_bill.cod_bill.by_recorded_at(@from_datetime,@to_datetime).order("recorded_at asc")
    end
    smart_listing_create :cod_sales_by_date, @bills, partial: "sale_reports/cod_sales_smartlisting"
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.pdf { render :layout => false } # Add this line  
      format.csv { send_data Bill.cod_reports_to_csv(@bills,@report_type_cod), filename: "sales-report-of-#{params[:from_date]}.csv" }
    end
  end

  def by_date_boh
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @report_type=''
    if params[:report_type].present?
      @report_type=params[:report_type]
      if params[:report_type]=="customer"
        @bills = Bill.unit_bills(@unit_id).valid_bill.boh_bill.by_recorded_at(@from_datetime,@to_datetime).bill_customer_group
      elsif params[:report_type]=="bill"
        @bills = Bill.unit_bills(@unit_id).valid_bill.boh_bill.by_recorded_at(@from_datetime,@to_datetime).order("recorded_at asc")        
      end
    else
      @bills = Bill.unit_bills(@unit_id).valid_bill.boh_bill.by_recorded_at(@from_datetime,@to_datetime).order("recorded_at asc")
    end
    smart_listing_create :boh_sales_by_date, @bills, partial: "sale_reports/boh_sales_smartlisting"
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.pdf { render :layout => false } # Add this line  
      format.csv { send_data Bill.boh_reports_to_csv(@bills,@report_type), filename: "sales-report-of-#{params[:from_date]}.csv" }
    end 
  end

  def by_date_boh_customer_wise
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @bills = Bill.unit_bills(@unit_id).valid_bill.boh_bill.by_recorded_at(@from_datetime,@to_datetime).group(:customer_id).sum(:boh_amount)
    smart_listing_create :boh_sales_by_date, @bills, partial: "sale_reports/boh_sales_smartlisting",default_sort: {recorded_at: "asc"}
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.pdf { render :layout => false } # Add this line   
      format.csv { send_data Bill.boh_reports_to_csv(@bills), filename: "sales-report-of-#{params[:from_date]}.csv" } 
    end
  end

  def by_date
    #_section_ids = Bill.select("DISTINCT(section_id)")
    #@sections = Section.where(:id => _section_ids)
    @deliverable = Bill.select("DISTINCT(deliverable_type)")
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @unit = Unit.find(@unit_id)
    @sections = @unit.sections
    @sales = Bill.valid_bill.unit_bills(@unit_id).order("recorded_at asc")
    @sales = @sales.by_recorded_at(@from_datetime,@to_datetime) if params[:from_date].present?
    @sales = @sales.check_bill_status(params[:status]) if params[:status].present?
    # @sales = @sales.set_deliverable_type(params[:deliverable_type]) if params[:deliverable_type].present?
    # @sales = @sales.section_bill(params[:section_id]) if params[:section_id].present? && params[:deliverable_type].present? && params[:deliverable_type] == "Section"
    if params[:deliverable_type].present?
      @sales = @sales.set_deliverable_type(params[:deliverable_type])
      if params[:deliverable_type] == "Section"
        @sales = @sales.section_bill(params[:section_id]) if params[:section_id].present?
      else
        @sales = @sales.by_section(params[:section_id]) if params[:section_id].present?
      end
    else
      @sales = @sales.by_section(params[:section_id]) if params[:section_id].present?
    end
    @sales = @sales.by_paymentmode_type(params[:paymentmode]) if params[:paymentmode].present?
    if params[:discountmode].present?
      @sales = @sales.only_discount_bills
    end
    @sales = @sales.by_paymentmode_type(params[:paymentmode]).third_party_payment_load(params[:third_party_id]) if params[:third_party_id].present?
    @sales = @sales.by_paymentmode_type(params[:paymentmode]).coupon_payment_load(params[:coupon_id]) if params[:coupon_id].present?

    @sales = @sales.joins(:orders).merge(Order.check_order_source(params[:order_sources])) if params[:order_sources].present?

    if params[:deliverable_type].present? && params[:deliverable_type]=='Resource'
      @total_sale = Bill.select("sum(bill_amount) as total_bill_amount, sum(grand_total) as total_grand_total, sum(tax_amount) as total_tax, sum(discount) as total_discount, sum(pax) as total_pax, sum(roundoff) as total_roundoff").unit_bills(@unit_id).by_recorded_at(@from_datetime,@to_datetime).valid_bill.set_deliverable_type(params[:deliverable_type])
    else
      @total_sale = Bill.select("sum(bill_amount) as total_bill_amount, sum(grand_total) as total_grand_total, sum(tax_amount) as total_tax, sum(discount) as total_discount, sum(pax) as total_pax, sum(roundoff) as total_roundoff").unit_bills(@unit_id).by_recorded_at(@from_datetime,@to_datetime).valid_bill
    end  
    smart_listing_create :sales_by_date, @sales, partial: "sale_reports/sales_by_date_smartlist",default_sort: {recorded_at: "asc"}
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.pdf { render :layout => false } # Add this line
      format.csv { send_data Bill.by_date_sales_to_csv(current_user.unit_id,@unit_id,@sales,@total_sale,@from_datetime,@to_datetime,params[:deliverable_type]), filename: "sales-report-of-#{params[:from_date]}.csv" }    
    end
  end

  def day_wise_tax_report
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @unit = Unit.find(@unit_id)
    @dates = (params[:from_date] .. params[:to_date]).select{|date| date if Date.valid_date? *date.split('-').map(&:to_i)}
    @total_sale = Bill.select("sum(bill_amount) as total_bill_amount, sum(grand_total) as total_grand_total, sum(tax_amount) as total_tax, sum(discount) as total_discount").unit_bills(@unit_id).by_recorded_at(@from_datetime,@to_datetime).valid_bill
    @tax_grup_amount=Bill.tax_grup_amount(@unit_id,@dates)
    @tax_group_head=Array.new
    @tax_grup_amount.each do |tg|
      @tax_group_head.push(tg["tax_group_id"]) unless @tax_group_head.include?(tg["tax_group_id"])
    end

    @unit_detail_options = @unit.unit_detail.options if current_user.present? && @unit.unit_detail.present?
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.csv { send_data Bill.day_wise_tax_report_to_csv(current_user.unit_id,@unit_id,@dates,@total_sale,@from_datetime,@to_datetime), filename: "sales-summary-report-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end
  end

  def by_date_range
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @unit = Unit.find(@unit_id)
    @dates = (params[:from_date] .. params[:to_date]).select{|date| date if Date.valid_date? *date.split('-').map(&:to_i)}
    @total_sale = Bill.select("sum(bill_amount) as total_bill_amount, sum(grand_total) as total_grand_total, sum(tax_amount) as total_tax, sum(discount) as total_discount").unit_bills(@unit_id).by_recorded_at(@from_datetime,@to_datetime).valid_bill

    #@sales = Bill.select("date(created_at) as date, sum(grand_total) as total_sale, sum(tax_amount) as total_tax, sum(discount) as total_discount").group("date(created_at)").unit_bills(current_user.unit_id).order("date(created_at)").check_bill_date_range(@from_datetime,@to_datetime).valid_bill

    @tax_persentage_group_amount=Bill.tax_persentage_group_amount(@unit_id,@dates)
    @tax_persentage_group_head=Array.new
    @tax_persentage_group_amount.each do |tg|
      if tg["tax_persentage_group"].to_f != 0
        @tax_persentage_group_head.push(tg["tax_persentage_group"]) unless @tax_persentage_group_head.include?(tg["tax_persentage_group"])
      end
    end

    @unit_detail_options = @unit.unit_detail.options if current_user.present? && @unit.unit_detail.present?
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.pdf { render :layout => false }
      format.csv { send_data Bill.sales_summary_to_csv(current_user.unit_id,@unit_id,@dates,@total_sale,@from_datetime,@to_datetime), filename: "sales-summary-report-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end
  end

  def sale_summery
    @unit_arr = params['unit_id'] if params['unit_id'].present? ? params['unit_id'] : current_user.unit_id
    @unit_arr = eval(params['units']) if params['units'].present?
    @from_date = params[:from_date]
    @to_date = params[:to_date]
    respond_to do |format|
      format.html # index.html.erb
      format.csv { send_data summery_to_csv(@unit_arr,@from_date,@to_date), filename: "summary-report-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end
  end

  def sale_user_wise
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    _user_id = Bill.by_unit(@unit_id).uniq.pluck(:biller_id)
    @users = User.includes([:profile]).find(_user_id)
    @unit = Unit.find(@unit_id)
    if params[:user_id].present?
      @user_sales = Bill.select("biller_id,date(recorded_at) as date, sum(grand_total) as total_grand_total, sum(tax_amount) as total_tax, sum(discount) as total_discount, sum(bill_amount) as total_bill_amount").group("date(recorded_at),biller_id").unit_bills(@unit_id).order("date(recorded_at)").by_recorded_at(@from_datetime,@to_datetime).valid_bill.by_biller(params[:user_id])
    else
      @user_sales = Bill.select("biller_id,date(recorded_at) as date, sum(grand_total) as total_grand_total, sum(tax_amount) as total_tax, sum(discount) as total_discount, sum(bill_amount) as total_bill_amount").group("date(recorded_at),biller_id").unit_bills(@unit_id).order("date(recorded_at)").by_recorded_at(@from_datetime,@to_datetime).valid_bill
    end      
    #smart_listing_create :sales_by_user, @user_sales, partial: "sale_reports/sales_by_user_smartlist"
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.pdf { render :layout => false }
      format.csv { send_data Bill.sale_user_wise_to_csv(@user_sales), filename: "sale-user-wise-report-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end
  end

  def category_wise
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @unit = Unit.find(@unit_id)
    @unit_detail_options = @unit.unit_detail.options if current_user.present? && @unit.unit_detail.present?
    @menu_card = MenuCard.find(params[:menu_card])
    @categories = @menu_card.menu_categories.where(:parent => nil)
    @category_sales = {}
    _from_datetime = params[:from_date].to_date.beginning_of_day+@unit_detail_options[:day_closing_time].to_i.hours if @unit.unit_detail.present?
    _from_datetime ||= params[:to_date].to_date.beginning_of_day
    _to_datetime = params[:to_date].to_date.end_of_day+@unit_detail_options[:day_closing_time].to_i.hours if @unit.unit_detail.present?
    _to_datetime ||= params[:to_date].to_date.end_of_day
    order_id_for_bill = Bill.by_recorded_at(_from_datetime,_to_datetime).valid_bill.map{|bill| bill.orders.map{|order| order.id}}.flatten
    if params[:category_id].present?  
      data = @menu_card.menu_categories.where('id =?', params[:category_id]).first
      sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.submenucategories.map{|category| category.menu_products.map{|product| product.id}}.flatten).sum("unit_price_without_tax * quantity")
      if AppConfiguration.get_config_value('zero_qty_sale_report') == "enabled"
        tax = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.submenucategories.map{|category| category.menu_products.map{|product| product.id}}.flatten).sum("tax_amount * quantity")
        if  @category_sales.has_key? data.name
          @category_sales[data.name]["sale"]["tax"] = @category_sales[data.name]["sale"].to_f+sale.to_f["tax"].to_f+tax.to_f
        else
          @category_sales[data.name] = {'sale'=>sale,'tax'=>tax,'children' => []}
        end
      else
        if sale > '0'  
          tax = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.submenucategories.map{|category| category.menu_products.map{|product| product.id}}.flatten).sum("tax_amount * quantity")
          if  @category_sales.has_key? data.name
            @category_sales[data.name]["sale"]["tax"] = @category_sales[data.name]["sale"].to_f+sale.to_f["tax"].to_f+tax.to_f
          else
            @category_sales[data.name] = {'sale'=>sale,'tax'=>tax,'children' => []}
          end
        end
      end
      data.submenucategories.each do |subcategory|
        sub_sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).sum("unit_price_without_tax * quantity")
        tmp = {}
        if AppConfiguration.get_config_value('zero_qty_sale_report') == "enabled"
          product_sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).group("menu_product_id,product_unique_identity").select("menu_product_id,SUM(discount) AS item_discount,SUM(unit_price_without_tax * quantity) as total_sale,SUM(tax_amount*quantity) as pro_tax, sum(material_cost) as pro_cost, SUM(quantity) as quantity,product_unique_identity")
          sub_tax = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).sum("tax_amount * quantity")
          tmp[subcategory.name]={'sale'=> sub_sale,'tax'=> sub_tax,'products'=> product_sale}
          @category_sales[data.name]['children'] << tmp
        else
          if sub_sale > '0'
            product_sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).group("menu_product_id,product_unique_identity").select("menu_product_id,SUM(discount) AS item_discount,SUM(unit_price_without_tax * quantity) as total_sale,SUM(tax_amount*quantity) as pro_tax, sum(material_cost) as pro_cost, SUM(quantity) as quantity,product_unique_identity")
            sub_tax = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).sum("tax_amount * quantity")
            tmp[subcategory.name]={'sale'=> sub_sale,'tax'=> sub_tax,'products'=> product_sale}
            @category_sales[data.name]['children'] << tmp
          end  
        end
      end     
    else  
      @menu_card.menu_categories.where(:parent => nil).each do |data| 
        sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.submenucategories.map{|category| category.menu_products.map{|product| product.id}}.flatten).sum("unit_price_without_tax * quantity")
        if AppConfiguration.get_config_value('zero_qty_sale_report') == "enabled"
          tax = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.submenucategories.map{|category| category.menu_products.map{|product| product.id}}.flatten).sum("tax_amount * quantity")
          if  @category_sales.has_key? data.name
            @category_sales[data.name]["sale"]["tax"] = @category_sales[data.name]["sale"].to_f+sale.to_f["tax"].to_f+tax.to_f
          else
            @category_sales[data.name] = {'sale'=>sale,'tax'=>tax,'children' => []}
          end
        else
          if sale > 0  
            tax = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.submenucategories.map{|category| category.menu_products.map{|product| product.id}}.flatten).sum("tax_amount * quantity")
            if  @category_sales.has_key? data.name
              @category_sales[data.name]["sale"]["tax"] = @category_sales[data.name]["sale"].to_f+sale.to_f["tax"].to_f+tax.to_f
            else
              @category_sales[data.name] = {'sale'=>sale,'tax'=>tax,'children' => []}
            end
          end
        end  
        data.submenucategories.each do |subcategory|
          sub_sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).sum("unit_price_without_tax * quantity")
          tmp = {}
          if AppConfiguration.get_config_value('zero_qty_sale_report') == "enabled"
            product_sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).group("menu_product_id,product_unique_identity,tax_details").select("menu_product_id,SUM(discount) AS item_discount,SUM(unit_price_without_tax * quantity) as total_sale,SUM(tax_amount*quantity) as pro_tax, sum(material_cost) as pro_cost, SUM(quantity) as quantity,product_unique_identity,tax_details")
            sub_tax = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).sum("tax_amount * quantity")
            tmp[subcategory.name]={'sale'=> sub_sale,'tax'=> sub_tax,'products'=> product_sale}
            @category_sales[data.name]['children'] << tmp
          else
            if sub_sale > 0
              product_sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).group("menu_product_id,product_unique_identity,tax_details").select("menu_product_id,SUM(discount) AS item_discount,SUM(unit_price_without_tax * quantity) as total_sale,SUM(tax_amount*quantity) as pro_tax, sum(material_cost) as pro_cost, SUM(quantity) as quantity,product_unique_identity,tax_details")
              sub_tax = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).sum("tax_amount * quantity")
              tmp[subcategory.name]={'sale'=> sub_sale,'tax'=> sub_tax,'products'=> product_sale}
              @category_sales[data.name]['children'] << tmp
            end  
          end
        end
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json {render json: @category_sales}
      format.pdf { render :layout => false }
      format.csv { send_data category_sales_to_csv(@category_sales), filename: "categor-sales-#{@menu_card.name}-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end

  end

  def sku_wise
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @sales = ActiveRecord::Base.connection.execute("select c.id, a.product_name, c.serial_no AS serial_no, a.product_unique_identity AS SKU, round(cast(a.unit_price_without_tax as numeric),2) AS Unit_price, 
      round(cast(a.tax_amount as numeric),2) AS Tax_Amount, round(cast(a.unit_price_without_tax as numeric),2) AS unit_price_without_tax,round(cast(a.unit_price_with_tax as numeric),2) AS unit_price_with_tax, a.quantity, round(a.subtotal) AS Subtotal, c.status,
      e.paymentmode_type AS Payment_Mode, c.recorded_at AS date from order_details a, bill_orders b, bills c, settlements d, payments e where a.order_id = b.order_id
      and b.bill_id=c.id and c.id=d.bill_id and d.id=e.settlement_id and c.recorded_at BETWEEN '#{@from_datetime}' AND '#{@to_datetime}' AND c.unit_id=#{@unit_id} order by c.recorded_at asc;")
    
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.csv { send_data sku_wise_to_csv(@sales), filename: "sales-report-sku-wise-#{params[:from_date]}.csv" }      
    end
  end

  def time_interval_wise
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @unit = Unit.find(@unit_id)
    @unit_detail_options = @unit.unit_detail.options if current_user.present? && @unit.unit_detail.present?
    menu_card = MenuCard.find(params[:menu_card])
    @categories = menu_card.menu_categories.where(:parent => nil)
    @category_sales = {}
    _from_datetime = DateTime.parse(params[:from_date]).strftime("%Y-%m-%d %H:%M:%S") #=> "convert in 24 hours"
    _from_datetime = Time.zone.parse(_from_datetime).utc
    _to_datetime = DateTime.parse(params[:to_date]).strftime("%Y-%m-%d %H:%M:%S")
    _to_datetime = Time.zone.parse(_to_datetime).utc
    order_id_for_bill = Bill.by_recorded_at(_from_datetime,_to_datetime).valid_bill.map{|bill| bill.orders.map{|order| order.id}}.flatten
    if params[:category_id].present?   
      data = menu_card.menu_categories.where('id =?', params[:category_id]).first
      sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.submenucategories.map{|category| category.menu_products.map{|product| product.id}}.flatten).sum("unit_price_without_tax * quantity")
      if sale > 0  
        tax = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.submenucategories.map{|category| category.menu_products.map{|product| product.id}}.flatten).sum("tax_amount * quantity")
        if  @category_sales.has_key? data.name
          @category_sales[data.name]["sale"]["tax"] = @category_sales[data.name]["sale"].to_f+sale.to_f["tax"].to_f+tax.to_f
        else
          @category_sales[data.name] = {'sale'=>sale,'tax'=>tax,'children' => []}
        end
      end 
      data.submenucategories.each do |subcategory|
        sub_sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).sum("unit_price_without_tax * quantity")
        tmp = {}
        if sub_sale > 0
          product_sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).group("menu_product_id,product_unique_identity").select("menu_product_id,SUM(unit_price_without_tax * quantity) as total_sale,SUM(tax_amount*quantity) as pro_tax, SUM(quantity) as quantity,product_unique_identity")
          sub_tax = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).sum("tax_amount * quantity")
          tmp[subcategory.name]={'sale'=> sub_sale,'tax'=> sub_tax,'products'=> product_sale}
          @category_sales[data.name]['children'] << tmp
        end  
      end     
    else  
      menu_card.menu_categories.where(:parent => nil).each do |data| 
        sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.submenucategories.map{|category| category.menu_products.map{|product| product.id}}.flatten).sum("unit_price_without_tax * quantity")
        if sale > 0  
          tax = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.submenucategories.map{|category| category.menu_products.map{|product| product.id}}.flatten).sum("tax_amount * quantity")
          if  @category_sales.has_key? data.name
            @category_sales[data.name]["sale"]["tax"] = @category_sales[data.name]["sale"].to_f+sale.to_f["tax"].to_f+tax.to_f
          else
            @category_sales[data.name] = {'sale'=>sale,'tax'=>tax,'children' => []}
          end
        end  
        data.submenucategories.each do |subcategory|
          sub_sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).sum("unit_price_without_tax * quantity")
          tmp = {}
          if sub_sale > 0
            product_sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).group("menu_product_id,product_unique_identity").select("menu_product_id,SUM(unit_price_without_tax * quantity) as total_sale,SUM(tax_amount*quantity) as pro_tax, SUM(quantity) as quantity,product_unique_identity")
            sub_tax = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>subcategory.menu_products.map{|product| product.id}).sum("tax_amount * quantity")
            tmp[subcategory.name]={'sale'=> sub_sale,'tax'=> sub_tax,'products'=> product_sale}
            @category_sales[data.name]['children'] << tmp
          end  
        end
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json {render json: @category_sales}
      format.pdf { render :layout => false }
      format.csv { send_data time_interval_sales_to_csv(@category_sales), filename: "time-interval-sales-#{menu_card.name}-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
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

  def adons_sales_reports
    _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id 
    @f_date = @from_datetime
    @t_date = @to_datetime
    if params[:section].present?
      @sections = Section.where('id =?', params[:section])
    else
      @sections = Unit.find(_unit_id).sections
    end  
    smart_listing_create :addons_report,@sections,partial: "sale_reports/addons_report_smartlist", page_sizes:[3]
    respond_to do |format|
      format.html
      format.js
      format.csv{send_data adons_sales_reports_csv(@sections,@f_date,@t_date),file_name: "adons_sale_report_#{params[:from_date]}-#{params[:to_date]}.csv"}
    end
  end

  private

  def set_module_details
    @module_id = "reports"
    @module_title = "Sales Report"
  end 

  def build_units_array
    @unit_arr = Array.new   
    params[:unit_ids].present? ? params[:unit_ids].map{|x| @unit_arr.push(x)} : @unit_arr.push(current_user.unit_id)
  end 

  def summery_to_csv(unit,from_datetime,to_datetime)
    CSV.generate do |csv|
      preferences = ReportPreference.by_unit(current_user.unit_id).by_key('sales_summery_report_by_date_range').first
      @pref = preferences.present? ? JSON.parse(preferences.allowed_attributes) : ["branch_name","grand_total","material_cost","percentage","unpaid_amt","settled_amt","cash","card","third_party","loyalty_card","discount"] 
      csv_header = Array.new
      csv_header.push("Branch Name") if @pref.include?('branch_name')
      csv_header.push("Grand Total") if @pref.include?('grand_total')
      csv_header.push("Material Cost") if @pref.include?('material_cost')
      csv_header.push("Percentage (%)") if @pref.include?('percentage')
      csv_header.push("Unpaid Amount") if @pref.include?('unpaid_amt')
      csv_header.push("Settled Amount") if @pref.include?('settled_amt')
      csv_header.push("Cash") if @pref.include?('cash')
      csv_header.push("Card") if @pref.include?('card')
      csv_header.push("Third party") if @pref.include?('third_party')
      csv_header.push("Loyalty") if @pref.include?('loyalty_card')
      csv_header.push("Discount") if @pref.include?('discount')
      csv << csv_header
      summery_total_sale = 0
      summery_meterial_cost = 0
      summery_total_settlement = 0
      summery_unpaid_amount = 0
      summery_cash_sale = 0
      summery_card_sale = 0
      summery_third_sale = 0
      summery_loyalty_sale = 0
      summery_discount = 0
      total_percentage = 0
      @unit_arr.each do |unit_id|
        if unit_id.present?
          if @from_date.to_date < "2016-04-01".to_date
            @from_date = "2016-04-01"
          end 
          unit = Unit.find(unit_id)
          unit_detail_options = unit.unit_detail.options if unit.unit_detail.present?
          _from_datetime = from_datetime.to_date.beginning_of_day+unit_detail_options[:day_closing_time].to_i.hours if unit.unit_detail.present?
          _from_datetime ||= from_datetime.to_date.beginning_of_day
          _to_datetime = to_datetime.to_date.end_of_day+unit_detail_options[:day_closing_time].to_i.hours if unit.unit_detail.present?
          _to_datetime ||= to_datetime.to_date.end_of_day   
          settlement_data = get_settlement_data_by_date(unit_id,_from_datetime,_to_datetime)
          _total_sale = Bill.unit_bills(unit_id).by_recorded_at(_from_datetime,_to_datetime).valid_bill.sum{|data| data.grand_total}
          meterial_cost = get_meterial_cost(unit_id,_from_datetime,_to_datetime)
          unpaid_amount = _total_sale.to_f - settlement_data[:total_settlement].to_f
          total_discount = Bill.unit_bills(unit_id).by_recorded_at(_from_datetime,_to_datetime).valid_bill.sum{|data| data.discount}
          summery_total_sale = summery_total_sale + _total_sale
          summery_meterial_cost = summery_meterial_cost + meterial_cost
          summery_unpaid_amount = summery_unpaid_amount + unpaid_amount
          summery_total_settlement = summery_total_settlement + settlement_data[:total_settlement].to_i
          summery_cash_sale = summery_cash_sale + settlement_data[:cash_sale].to_i
          summery_card_sale = summery_card_sale + settlement_data[:card_sale].to_i
          summery_third_sale = summery_third_sale + settlement_data[:third_party_sale].to_i
          summery_loyalty_sale = summery_loyalty_sale + settlement_data[:loyalty_card_sale].to_i
          summery_discount = summery_discount + total_discount
          percentage = (meterial_cost/_total_sale)*100
          percentage = (percentage.is_a?(Float) && percentage.nan?) ? 0 : percentage
          total_percentage = (summery_meterial_cost/summery_total_sale)*100
          total_percentage = (total_percentage.is_a?(Float) && total_percentage.nan?) ? 0 : total_percentage
          csv_result = Array.new
          csv_result.push(unit.unit_name) if @pref.include?('branch_name')
          csv_result.push(_total_sale) if @pref.include?('grand_total')
          csv_result.push(meterial_cost.round(2)) if @pref.include?('material_cost')
          csv_result.push(percentage.round(2)) if @pref.include?('percentage')
          csv_result.push(unpaid_amount.round(2)) if @pref.include?('unpaid_amt')
          csv_result.push(settlement_data[:total_settlement]) if @pref.include?('settled_amt')
          csv_result.push(settlement_data[:cash_sale]) if @pref.include?('cash')
          csv_result.push(settlement_data[:card_sale]) if @pref.include?('card')
          csv_result.push(settlement_data[:third_party_sale]) if @pref.include?('third_party')
          csv_result.push(settlement_data[:loyalty_card_sale]) if @pref.include?('loyalty_card')
          csv_result.push(total_discount) if @pref.include?('discount')
          csv << csv_result
        end
      end 
      _blank = Array.new
      summery_array = Array.new
      _blank.push()
      csv<<_blank
      summery_array.push("Sale Summary") if @pref.include?('branch_name')
      summery_array.push(summery_total_sale) if @pref.include?('grand_total')
      summery_array.push(summery_meterial_cost.round(2)) if @pref.include?('material_cost')
      summery_array.push(total_percentage.round(2)) if @pref.include?('percentage')
      summery_array.push(summery_unpaid_amount.round(2)) if @pref.include?('unpaid_amt')
      summery_array.push(summery_total_settlement) if @pref.include?('settled_amt')
      summery_array.push(summery_cash_sale) if @pref.include?('cash')
      summery_array.push(summery_card_sale) if @pref.include?('card')
      summery_array.push(summery_third_sale) if @pref.include?('third_party')
      summery_array.push(summery_loyalty_sale) if @pref.include?('loyalty_card')
      summery_array.push(summery_discount) if @pref.include?('discount')
      csv<<summery_array
    end  
  end

  # def category_sales_to_csv(data)
  #   CSV.generate do |csv|
  #     _total_sale = 0
  #     _sell_price_without_tax = 0
  #     _quantity = 0
  #     csv << [ "Main Category","Sub Category",'Product','SKU','Quantity','Sale(Without Tax)','tax']
  #     @category_sales.each do |main_cat,data|
  #       csv << [main_cat,'','','','',data['sale'],data['tax']]
  #       data["children"].each do |sub_cat_data|
  #         csv << ['',sub_cat_data.keys.first,'','','',sub_cat_data[sub_cat_data.keys.first]["sale"],sub_cat_data[sub_cat_data.keys.first]["tax"]]
  #         sub_cat_data[sub_cat_data.keys.first]["products"].each do |product|
  #           _total_sale = _total_sale + product.total_sale.to_i 
  #           _sell_price_without_tax = _sell_price_without_tax + product.menu_product.sell_price_without_tax.to_i
  #           _quantity =  _quantity + product.quantity
  #           csv << ['','',product.menu_product.product.name,product.product_unique_identity,product.quantity,product.total_sale,product.pro_tax]
  #         end
  #       end
  #     end
  #     _blank = Array.new
  #     _blank.push()
  #     csv<<_blank
  #     csv<<["Total Quantity","Total Sale(Without Tax)"]
  #     csv<<[_quantity,_total_sale]
  #   end
  # end

  def category_sales_to_csv(data)
    CSV.generate do |csv|
      csv_menu = Array.new()
      csv_menu << MenuCard.find(params[:menu_card]).name
      preferences = ReportPreference.by_unit(current_user.unit_id).by_key('category_wise_sales_report').first
      @pref = preferences.present? ? JSON.parse(preferences.allowed_attributes) : ["main_cetegory","sub_cetegory","product","quantity","average_cost","total_cost","sale_price","sale_without_tax"] 
      csv_header = Array.new
      csv_header.push("Main Category") if @pref.include?('main_cetegory')
      csv_header.push("Sub Category") if @pref.include?('sub_cetegory')
      csv_header.push("Product") if @pref.include?('product')
      csv_header.push("Sku") if @pref.include?('sku')
      csv_header.push("Hsn Code") if @pref.include?('hsn_code')
      csv_header.push("Quantity") if @pref.include?('quantity')
      csv_header.push("Average Cost") if @pref.include?('average_cost')
      csv_header.push("Total Cost") if @pref.include?('total_cost')
      csv_header.push("Unit Price") if @pref.include?('sale_price')
      csv_header.push("Total Sale(Without Tax)") if @pref.include?('sale_without_tax')
      csv_header.push("Sgst%") if @pref.include?('sgst_percentage')
      csv_header.push("Cgst%") if @pref.include?('cgst_percentage')
      csv_header.push("Sgst") if @pref.include?('sgst')
      csv_header.push("Cgst") if @pref.include?('cgst')
      csv_header.push("Gst") if @pref.include?('gst')
      csv_header.push("Tax") if @pref.include?('tax')
      csv_header.push("Sale Price(With Tax)") if @pref.include?('sale_with_tax')
      csv_header.push("Item Discount") if @pref.include?('item_discount')
      _total_sale = 0
      _item_discount = 0
      _sell_price_without_tax = 0
      _quantity = 0
      _total_ave_cost = 0
      _total_cost = 0
      _total_gst = 0
      _total_tax = 0
      csv << csv_menu
      csv << csv_header
      @category_sales.each do |main_cat,data|
        _total_tax = _total_tax + data['tax'].to_f
        csv_cetegoryes = Array.new
        csv_cetegoryes.push(main_cat) if @pref.include?('main_cetegory')
        csv_cetegoryes.push('') if @pref.include?('sub_cetegory')
        csv_cetegoryes.push('') if @pref.include?('product')
        csv_cetegoryes.push('') if @pref.include?('sku')
        csv_cetegoryes.push('') if @pref.include?('hsn_code')
        csv_cetegoryes.push('') if @pref.include?('quantity')
        csv_cetegoryes.push('') if @pref.include?('average_cost')
        csv_cetegoryes.push('') if @pref.include?('total_cost')
        csv_cetegoryes.push('') if @pref.include?('sale_price')
        csv_cetegoryes.push(data['sale']) if @pref.include?('sale_without_tax')
        csv_cetegoryes.push('') if @pref.include?('sgst_percentage')
        csv_cetegoryes.push('') if @pref.include?('cgst_percentage')
        csv_cetegoryes.push('') if @pref.include?('sgst')
        csv_cetegoryes.push('') if @pref.include?('cgst')
        csv_cetegoryes.push('') if @pref.include?('gst')
        csv_cetegoryes.push(data['tax']) if @pref.include?('tax')
        csv_cetegoryes.push(data['sale'].to_f + data['tax'].to_f) if @pref.include?('sale_with_tax')
        csv << csv_cetegoryes
        data["children"].each do |sub_cat_data|
          csv_sub_cetegoryes = Array.new
          csv_sub_cetegoryes.push('') if @pref.include?('main_cetegory')
          csv_sub_cetegoryes.push(sub_cat_data.keys.first) if @pref.include?('sub_cetegory')
          csv_sub_cetegoryes.push('') if @pref.include?('product')
          csv_sub_cetegoryes.push('') if @pref.include?('sku')
          csv_sub_cetegoryes.push('') if @pref.include?('hsn_code')
          csv_sub_cetegoryes.push('') if @pref.include?('quantity')
          csv_sub_cetegoryes.push('') if @pref.include?('average_cost')
          csv_sub_cetegoryes.push('') if @pref.include?('total_cost')
          csv_sub_cetegoryes.push('') if @pref.include?('sale_price')
          csv_sub_cetegoryes.push(sub_cat_data[sub_cat_data.keys.first]["sale"]) if @pref.include?('sale_without_tax')
          csv_sub_cetegoryes.push('') if @pref.include?('sgst_percentage')
          csv_sub_cetegoryes.push('') if @pref.include?('cgst_percentage')
          csv_sub_cetegoryes.push('') if @pref.include?('sgst')
          csv_sub_cetegoryes.push('') if @pref.include?('cgst')
          csv_sub_cetegoryes.push('') if @pref.include?('gst')
          csv_sub_cetegoryes.push(sub_cat_data[sub_cat_data.keys.first]["tax"]) if @pref.include?('tax')
          csv_sub_cetegoryes.push(sub_cat_data[sub_cat_data.keys.first]["sale"].to_f + sub_cat_data[sub_cat_data.keys.first]["tax"].to_f) if @pref.include?('sale_with_tax')
          csv << csv_sub_cetegoryes
          sub_cat_data[sub_cat_data.keys.first]["products"].each do |product|
            _gst = 0
            _total_sale = _total_sale + product.total_sale.to_f
            _item_discount = _item_discount + product.item_discount.to_f
            _sell_price_without_tax = _sell_price_without_tax + product.menu_product.sell_price_without_tax.to_i
            _quantity =  _quantity + product.quantity
            _ave_cost = (product.pro_cost.to_f / product.quantity).round(2)
            _total_ave_cost = _total_ave_cost + _ave_cost
            _total_cost = _total_cost + product.pro_cost.to_f.round(2)
            csv_product = Array.new
            csv_product.push('') if @pref.include?('main_cetegory')
            csv_product.push('') if @pref.include?('sub_cetegory')
            csv_product.push(product.menu_product.product.name) if @pref.include?('product')
            csv_product.push(product.product_unique_identity) if @pref.include?('sku')
            csv_product.push(product.menu_product.product.hsn_code) if @pref.include?('hsn_code')
            csv_product.push(product.quantity) if @pref.include?('quantity')
            csv_product.push(_ave_cost) if @pref.include?('average_cost')
            csv_product.push(product.pro_cost.to_f.round(2)) if @pref.include?('total_cost')
            csv_product.push(product.menu_product.sell_price_without_tax) if @pref.include?('sale_price')
            csv_product.push(product.total_sale) if @pref.include?('sale_without_tax')
            # if @pref.include?('sgst_percentage')
            #   product.menu_product.tax_group.tax_classes.each do |tax|  
            #     csv_product.push("#{tax.ammount}" "(%)")
            #   end
            # end
            if @pref.include?('sgst_percentage')
              if product.tax_details.present?
                JSON.parse(product.tax_details).each do |tax|
                  csv_product.push("#{tax["tax_percentage"]}" "(%)")
                end
              end  
            end
            # if @pref.include?('cgst')
            #   product.menu_product.tax_group.tax_classes.each do |tax|
            #     _gst += (product.total_sale.to_f * tax.ammount)/100
            #     _total_gst += (product.total_sale.to_f * tax.ammount)/100 
            #     csv_product.push((product.total_sale.to_f * tax.ammount)/100) 
            #   end  
            # end 
            if @pref.include?('cgst')
              if product.tax_details.present?
                JSON.parse(product.tax_details).each do |tax|
                  _gst += (product.total_sale.to_f * tax["tax_percentage"])/100
                  _total_gst += (product.total_sale.to_f * tax["tax_percentage"])/100 
                  csv_product.push((product.total_sale.to_f * tax["tax_percentage"])/100) 
                end  
              end  
            end  
            csv_product.push(_gst) if @pref.include?('gst')
            csv_product.push(product.pro_tax) if @pref.include?('tax')
            csv_product.push(product.total_sale.to_f + product.pro_tax.to_f) if @pref.include?('sale_with_tax')
            csv_product.push(product.item_discount.to_f) if @pref.include?('item_discount')
            csv << csv_product
          end
        end
      end
      _blank = Array.new
      _blank.push()
      csv<<_blank
      # csv<<["Total Quantity","Total Unit Cost","Total Cost","Total Unit Price","Total Sale(Without Tax)"]
      # csv<<[_quantity,_total_ave_cost.round(2),_total_cost.round(2),_sell_price_without_tax,_total_sale.round(2)]
      csv<<["Total Quantity","Total Unit Cost","Total Cost","Total Unit Price","Total Sale(Without Tax)","Total Cgst", "Total Sgst", "Total Gst", "Total Sale(with tax)", "Total Item Discount"]
      csv<<[_quantity,_total_ave_cost.round(2),_total_cost.round(2),_sell_price_without_tax,_total_sale.round(2),_total_gst/2, _total_gst/2 ,_total_gst, (_total_sale + _total_tax).round(2), _item_discount.round(2)]
    end
  end

  def time_interval_sales_to_csv(data)
    CSV.generate do |csv|
      _total_sale = 0
      _sell_price_without_tax = 0
      _quantity = 0
      csv << [ "Main Category","Sub Category",'Product','SKU','Quantity','Sale(Without Tax)','tax']
      @category_sales.each do |main_cat,data|
        csv << [main_cat,'','','','',data['sale'],data['tax']]
        data["children"].each do |sub_cat_data|
          csv << ['',sub_cat_data.keys.first,'','','',sub_cat_data[sub_cat_data.keys.first]["sale"],sub_cat_data[sub_cat_data.keys.first]["tax"]]
          sub_cat_data[sub_cat_data.keys.first]["products"].each do |product|
            _total_sale = _total_sale + product.total_sale.to_i 
            _sell_price_without_tax = _sell_price_without_tax + product.menu_product.sell_price_without_tax.to_i
            _quantity =  _quantity + product.quantity
            csv << ['','',product.menu_product.product.name,product.product_unique_identity,product.quantity,product.total_sale,product.pro_tax]
          end
        end
      end
      _blank = Array.new
      _blank.push()
      csv<<_blank
      csv<<["Total Quantity","Total Sale(Without Tax)"]
      csv<<[_quantity,_total_sale]
    end
  end

  def sku_wise_to_csv(sales)
    CSV.generate do |csv|
      preferences = ReportPreference.by_unit(current_user.unit_id).by_key('sales_report_by_date_sku').first
      _pref = preferences.present? ? JSON.parse(preferences.allowed_attributes) : ["bill_id","product_name","serial_no","sku","unit_price_without_tax","tax_amount","quantity","subtotal","status","payment_mode","name","phone_no","date"]
      _pref_humanize =  _pref.map{|x| (x.humanize)}
      csv << _pref_humanize
      sales.each do |sale|
        bill= Bill.find(sale["id"])
        _row = Array.new
        _row.push(sale["id"]) if _pref.include?('bill_id')
        _row.push(sale["product_name"]) if _pref.include?('product_name')
        _row.push("#{bill.prefix}""#{bill.serial_no}""#{bill.suffix}") if _pref.include? ('serial_no')
        _row.push(sale["sku"]) if _pref.include?('sku')
        _row.push(sale["unit_price_without_tax"]) if _pref.include?('unit_price_without_tax')
        _row.push(sale["unit_price_with_tax"]) if _pref.include?('unit_price_with_tax')
        _row.push(sale["tax_amount"]) if _pref.include?('tax_amount')
        _row.push(sale["quantity"]) if _pref.include?('quantity')
        _row.push(sale["subtotal"]) if _pref.include?('subtotal')
        _row.push(sale["status"]) if _pref.include?('status')
        _row.push(sale["payment_mode"]) if _pref.include?('payment_mode')
        if bill.customer.present? && _pref.include?('name')
          if bill.customer.customer_profile.customer_name.present? 
            _row.push(bill.customer.customer_profile.customer_name) 
          else  
            _row.push("#{bill.customer.customer_profile.firstname}"" #{bill.customer.customer_profile.lastname}")
          end
        else
          _row.push("")
        end  
        if bill.customer.present? && _pref.include?('phone_no')
          _row.push(bill.customer.mobile_no) 
        else
          _row.push("")
        end  
        _row.push(Date.parse(sale["date"]).strftime("%d-%m-%Y")) if _pref.include?('date')
        csv << _row
      end  
    end  
  end
  def adons_sales_reports_csv(sections,f_date,t_date)
    CSV.generate do |csv|
      csv<<["Section","Addons Name","Product Price","Quantity","Total Price"]
      sections.each do |section|
        add_on_sales = add_on_sales(section.unit_id,section.id,f_date,t_date)
        csv << [section.name,"","","",""]
        add_on_sales.each do|object|
          product = Product.find(object.product_id)
          csv << ["",object.product_name,object.product_price,"#{object.quantity}"" #{product.basic_unit}",object.total_price]
        end
      end  
    end
  end 
end