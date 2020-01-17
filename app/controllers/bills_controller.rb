class BillsController < ApplicationController
  #http_basic_authenticate_with name: "webadmin", password: "welome@12345", only: :edit
  load_and_authorize_resource :except => [:create, :split_bill, :get_unsetteled_bills, :edit, :update, :get_bill_by_serial]
  layout "material"

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  before_filter :set_module_details, only: [:index, :show, :edit]
  before_filter :get_current_user, only: [:index] #Getting current user
  before_filter :set_bill, only: [:split_bill, :update] #Setting bill
  before_filter :set_timerange, only: [:index]

  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  api :GET, '/bills.json', "Get all bills for a unit."
  error :code => 401, :desc => "Unauthorized"
  param :unit_id, String, :desc => "Outlet ID (required)"
  param :status, nil, :desc => "Bill Status: (unpaid, paid, void, no_charge, cod)"
  param :deliverable_type, String, :desc => "Deliverable Type"
  param :deliverable_id, String, :desc => "Deliverable ID"
  param :from_price, String, :desc => "From bill amount"
  param :to_price, String, :desc => "To bill amount"
  param :from_date, String, :desc => "From date"
  param :to_date, String, :desc => "To date"
  description " API URL : http://dev.selfordering.com/bills.json?device_id=YOTTO05&unit_id=2&deliverable_id=7&deliverable_type=table"
  formats ['json']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  # GET /bills
  # GET /bills.json


  def index
    _unit_id = params[:unit_id].present? ? params[:unit_id] : @current_user.unit_id
    #@distinct_sections = Bill.distinct_section
    @distinct_sections = Section.where("unit_id =?",_unit_id)
    @return_stores = Store.where( "store_type = ? and unit_id = ?", "return_store", _unit_id )
    @maxbill = Bill.maximum('grand_total')
    # @bills = Bill.includes([:orders]).where("bills.unit_id" => _unit_id).order("bills.created_at desc")
    if params[:is_cancel].present?
      @bills_ids = Bill.select("bills.id").uniq.joins(:orders).where(orders: { trash: 1 }).where(bills: { unit_id: _unit_id })
      _arr_b_ids=[]
      @bills_ids.each do |bid|
        _arr_b_ids.push(bid.id)
      end
      @bills = Bill.where_id_in(_arr_b_ids).order("bills.created_at desc")
      # @bills = Bill.joins(:orders).where(bills: { unit_id: _unit_id }).where(orders: { trash: 1 }).order("bills.created_at desc")
    else
      @bills = Bill.includes([:orders]).where("bills.unit_id" => _unit_id ).order("bills.created_at desc")
    end
    @bills = @bills.where("orders.source" => params[:order_source]) if params[:order_source].present?
    @bills = @bills.set_id(params[:id_filter]) if params[:id_filter].present?
    @bills = @bills.check_bill_status(params[:status]) if params[:status].present?
    @bills = @bills.set_deliverable_type(params[:deliverable_type]) if params[:deliverable_type].present?
    @bills = @bills.set_deliverable_id(params[:deliverable_id]) if params[:deliverable_id].present?
    @bills = @bills.section_bill(params[:section_id]) if params[:section_id].present?
    @bills = @bills.by_paymentmode_type(params[:paymentmode]) if params[:paymentmode].present?
    @bills = @bills.by_paymentmode_type(params[:paymentmode]).third_party_payment_load(params[:third_party_id]) if params[:third_party_id].present?
    @bills = @bills.by_paymentmode_type(params[:paymentmode]).coupon_payment_load(params[:coupon_id]) if params[:coupon_id].present?
    @bills = @bills.check_price_range(params[:from_price],params[:to_price]) if params[:from_price].present? && params[:to_price].present?
    @bills = @bills.by_recorded_at(@from_datetime,@to_datetime) if params[:from_date].present?
    @bills = @bills.by_user_login(params[:login]) if params[:login].present?
    @bills = @bills.only_discount_bills if params[:is_discount].present?
    smart_listing_create :bills, @bills, partial: "bills/bills_smartlist", default_sort: {created_at: "desc"}
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bills.order("created_at desc").to_json(:include => [{:bill_splits => {:include => :bill_split_products}}, {:orders => {:include => [:order_details => {:include => :order_detail_combinations}]}}, :payments, {:bill_tax_amounts => {:include => :tax_class}},{:biller => {:include => :profile}}] ) }
      format.js
    end
  end


  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  api :GET, '/bills/get_unsetteled_bills.json', "Get all un-setteled bills for a deliverable type."
  error :code => 401, :desc => "Unauthorized"
  param :unit_id, String, :desc => "Outlet ID", :required => true
  param :status, nil, :desc => "Bill Status: (unpaid, paid, void, no_charge, cod)"
  param :deliverable_type, String, :desc => "Deliverable Type"
  param :deliverable_id, String, :desc => "Deliverable ID"
  description " API URL : http://dev.selfordering.com/bills/get_unsetteled_bills.json?device_id=YOTTO05&unit_id=2&deliverable_id=7&deliverable_type=table"
  formats ['json']


  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def get_unsetteled_bills
    _bills = Bill.unit_bills(params[:unit_id])
    _status = params[:status].present? ? params[:status] : ['unpaid','cod']
    _bills = _bills.check_bill_status(_status)
    _bills = _bills.set_deliverable_type(params[:deliverable_type]) if params[:deliverable_type].present?
    _bills = _bills.set_deliverable_id(params[:deliverable_id]) if params[:deliverable_id].present?
    respond_to do |format|
      format.json { render json: _bills.to_json(:include => [{:bill_splits => {:include => :bill_split_products}}, {:orders => {:include => [:order_details => {:include => :order_detail_combinations}]}}, :payments, {:bill_tax_amounts => {:include => :tax_class}}] ) }
    end
  end


  # GET /bills/1
  # GET /bills/1.json
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  api :GET, '/bills/:id.json', "Fetch a bill details."
  error :code => 401, :desc => "Unauthorized"
  description "In the following URL 1 is the bill ID URL : http://lazeez.stewot.com/bills/1.json?device_id=YOTTO05"
  formats ['json', 'html']
  example "{'bill_amount':60.0,'created_at':'2015-08-17T16:29:14Z','deliverable_id':39,'deliverable_type':'Address','discount':0.0,'grand_total':68.4,'id':169,'order_sr_no':null,'status':'unpaid','tax_amount':8.4,'tax_details':null,'unit_id':5,'updated_at':'2015-08-17T16:29:14Z','user_id':4,'bill_splits':[],'orders':[{'billed':1,'cancel_cause':null,'consumer_id':4,'consumer_type':'User','created_at':'2015-08-17T16:29:13Z','delivary_date':'2015-08-17T20:52:00Z','deliverable_id':39,'deliverable_type':'Address','delivery_boy_id':null,'id':205,'order_sr_no':null,'order_status_id':2,'order_subtotal':68.4,'order_total_without_tax':60.0,'source':'fos','total_discount':0.0,'total_tax':8.4,'trash':0,'unit_id':5,'updated_at':'2015-08-17T16:29:14Z','user_id':null,'order_details':[{'bill_status':null,'cancel_cause':null,'created_at':'2015-08-17T16:29:13Z','customization_price':10.0,'discount':0.0,'id':279,'is_stock_debited':'yes','menu_product_id':209,'order_id':205,'parcel':1,'preferences':'','procurement_cost':40.0,'product_id':43,'product_name':'Tomato Soup','product_price':50.0,'quantity':1,'sort_id':2,'status':'approved','subtotal':68.4,'tax_amount':8.4,'tax_details':'[{\'tax_class_name\':\'simple 2\',\'tax_type\':\'simple\',\'tax_percentage\':\'14\',\'tax_amount\':8.4}]','trash':0,'unit_id':5,'unit_price_with_tax':68.4,'unit_price_without_tax':60.0,'updated_at':'2015-08-17T16:29:14Z','order_detail_combinations':[{'combination_qty':1,'created_at':'2015-08-17T16:29:13Z','id':35,'is_stock_debited':'yes','menu_product_combination_id':258,'order_detail_id':279,'product_id':32,'product_name':'Bread','product_price':10.0,'status':'approved','total_price':10.0,'unit_id':5,'updated_at':'2015-08-17T16:29:14Z'}]}]}]}"
  

  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def show
    @bill = Bill.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bill.to_json(:include => [{:bill_splits => {:include => :bill_split_products}}, {:orders => {:include => [:order_details => {:include => :order_detail_combinations}]}}, {:settlement => {:include => [:payments => {:include => :paymentmode}]}}, {:payments => {:include => :paymentmode}}, {:bill_tax_amounts => {:include => :tax_class}}, :bill_discounts,{:biller => {:include => :profile}}] ) }
    end
  end

  
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  api :POST, '/bills.json', "Generate a new bill."
  error :code => 401, :desc => "Unauthorized"
  param :order_ids, String, :desc => "All order ids in raw JSON format. Sample JSON : [{'order_id':'3'},{'order_id':'4'},{'order_id':'5'}]  ", :required => true
  param :recorded_at, String, :desc => "Bill record datetime", :required => false
  param :bill_amount, String, :desc => "Bill Amount", :required => true
  param :discount, String, :desc => "Bill Discount", :required => true
  param :grand_total, String, :desc => "Total Bill amount", :required => true
  param :tax_amount, String, :desc => "Total tax amount", :required => true
  param :tax_details, String, :desc => "All tax details in raw JSON format having two key-value pair, tax_class_id, tax_amount. Sample JSON : [{'tax_class_id':4,'tax_amount':'100'},{'tax_class_id':6,'tax_amount':'200'}]  ", :required => true
  param :unit_id, String, :desc => "Outlet ID", :required => true
  param :biller_id, String, :desc => "Biller ID", :required => false
  param :biller_type, String, :desc => "Biller type", :required => false
  param :user_id, String, :desc => "User ID", :required => true
  param :deliverable_id, String, :desc => "Deliverable ID", :required => true
  param :deliverable_type, String, :desc => "Deliverable Type", :required => true
  param :serial_no, String, :desc => "Bill serial no", :required => false
  param :pax, String, :desc => "Total PAX", :required => false
  param :remarks, String, :desc => "Any remarks", :required => false
  description " API URL : http://lazeez.stewot.com/bills.json?device_id=YOTTO05"
  example "{'bill_amount':60.0,'created_at':'2015-08-17T16:29:14Z','deliverable_id':39,'deliverable_type':'Address','discount':0.0,'grand_total':68.4,'id':169,'order_sr_no':null,'status':'unpaid','tax_amount':8.4,'tax_details':null,'unit_id':5,'updated_at':'2015-08-17T16:29:14Z','user_id':4,'bill_splits':[],'orders':[{'billed':1,'cancel_cause':null,'consumer_id':4,'consumer_type':'User','created_at':'2015-08-17T16:29:13Z','delivary_date':'2015-08-17T20:52:00Z','deliverable_id':39,'deliverable_type':'Address','delivery_boy_id':null,'id':205,'order_sr_no':null,'order_status_id':2,'order_subtotal':68.4,'order_total_without_tax':60.0,'source':'fos','total_discount':0.0,'total_tax':8.4,'trash':0,'unit_id':5,'updated_at':'2015-08-17T16:29:14Z','user_id':null,'order_details':[{'bill_status':null,'cancel_cause':null,'created_at':'2015-08-17T16:29:13Z','customization_price':10.0,'discount':0.0,'id':279,'is_stock_debited':'yes','menu_product_id':209,'order_id':205,'parcel':1,'preferences':'','procurement_cost':40.0,'product_id':43,'product_name':'Tomato Soup','product_price':50.0,'quantity':1,'sort_id':2,'status':'approved','subtotal':68.4,'tax_amount':8.4,'tax_details':'[{\'tax_class_name\':\'simple 2\',\'tax_type\':\'simple\',\'tax_percentage\':\'14\',\'tax_amount\':8.4}]','trash':0,'unit_id':5,'unit_price_with_tax':68.4,'unit_price_without_tax':60.0,'updated_at':'2015-08-17T16:29:14Z','order_detail_combinations':[{'combination_qty':1,'created_at':'2015-08-17T16:29:13Z','id':35,'is_stock_debited':'yes','menu_product_combination_id':258,'order_detail_id':279,'product_id':32,'product_name':'Bread','product_price':10.0,'status':'approved','total_price':10.0,'unit_id':5,'updated_at':'2015-08-17T16:29:14Z'}]}]}]}"
  formats ['json']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  
  def create
    begin
      ActiveRecord::Base.transaction do # Protective transaction block
        @bill = Bill.new(bill_params)
        if @bill.save
          respond_to do |format|
            format.json { render json: @bill.reload.to_json(:include => [{:bill_splits => {:include => :bill_split_products}}, {:orders => {:include => [:order_details => {:include => :order_detail_combinations}]}}, :payments, {:bill_tax_amounts => {:include => :tax_class}}, :bill_discounts] ) }
          end
        else
          raise error_messages_for(@bill)
        end
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      respond_to do |format|
        format.json { render json: {:error=> e.message.to_s}, status: :unprocessable_entity }
      end
    end
  end

  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  api :PUT, '/bills/:id.json', "Edit a bill details."
  error :code => 401,         :desc => "Unauthorized"
  param :bill_id,     String, :desc => "Bill ID", :required => true
  param :bill_amount, String, :desc => "Bill Amount"
  param :tax_amount,  String, :desc => "Total tax amount"
  param :discount,    String, :desc => "Bill Discount"
  param :grand_total, String, :desc => "Total Bill amount"
  param :status,      String, :desc => "Bill Status: (unpaid, paid, void, no_charge, cod)"
  description " API URL : http://dev.selfordering.com/bills/1.json?device_id=YOTTO05"
  example "{'bill_amount':50.0,'created_at':'2015-08-05T11:17:20Z','deliverable_id':21,'deliverable_type':'Table','discount':0.0,'grand_total':57.0,'id':99,'order_sr_no':null,'status':'unpaid','tax_amount':7.0,'tax_details':null,'unit_id':5,'updated_at':'2015-08-05T11:17:20Z','user_id':1,'bill_splits':[],'orders':[{'billed':1,'cancel_cause':null,'consumer_id':4,'consumer_type':'User','created_at':'2015-08-05T11:17:17Z','delivary_date':'2015-08-05T16:34:08Z','deliverable_id':21,'deliverable_type':'Table','delivery_boy_id':null,'id':123,'order_sr_no':null,'order_status_id':2,'order_subtotal':57.0,'order_total_without_tax':50.0,'source':'fos','total_discount':0.0,'total_tax':7.0,'trash':0,'unit_id':5,'updated_at':'2015-08-05T11:17:20Z','user_id':null,'order_details':[{'bill_status':null,'cancel_cause':null,'created_at':'2015-08-05T11:17:17Z','customization_price':0.0,'discount':0.0,'id':197,'is_stock_debited':'yes','menu_product_id':209,'order_id':123,'parcel':1,'preferences':'','procurement_cost':40.0,'product_id':43,'product_name':'Tomato Soup','product_price':50.0,'quantity':1,'sort_id':2,'status':'approved','subtotal':57.0,'tax_amount':7.0,'tax_details':'[{\'tax_class_name\':\'simple 2\',\'tax_type\':\'simple\',\'tax_percentage\':\'14\',\'tax_amount\':7.0}]','trash':0,'unit_id':5,'unit_price_with_tax':57.0,'unit_price_without_tax':50.0,'updated_at':'2015-08-05T11:17:18Z','order_detail_combinations':[]}]}]}"
  formats ['json']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#

  def update
    begin
      ActiveRecord::Base.transaction do # Protective transaction block
      Bill.update_bill_amounts(@bill)
      Bill.calculate_bill_taxes(@bill)
      @bill.bill_discounts << BillDiscount.new(:discount_amount=>params[:discount], :remarks=>params[:remarks]) if params[:discount].present?
      @bill.update_attributes(:status=>params[:status], :remarks=>params[:remarks]) if params[:status].present?
      Bill.apply_promo_code(@bill,params[:promo_code]) if params[:promo_code].present?
      if @bill.deliverable_type == 'Table'
        Table.update_table_state(1,@bill.unit_id,@bill.deliverable_id,@bill.biller_id,@bill.device_id) if params[:status].present? && params[:status] == 'void' || params[:status] == 'no_charge'
      elsif @bill.deliverable_type == 'Resource'
        Resource.update_resource_state(1,@bill.unit_id,@bill.deliverable_id,@bill.biller_id,@bill.device_id) if params[:status].present? && params[:status] == 'void' || params[:status] == 'no_charge'
      end
      respond_to do |format|
        format.html {redirect_to bill_path(@bill.reload)}
        format.json { render json: @bill.reload.to_json(:include => [{:bill_splits => {:include => :bill_split_products}}, {:orders => {:include => [:order_details => {:include => :order_detail_combinations}]}}, :payments, {:bill_tax_amounts => {:include => :tax_class}}, :bill_discounts] ) }
      end
    end
    rescue Exception => e
      Rscratch::Exception.log e,request
      respond_to do |format|
        format.html {redirect_to edit_bill_path(@bill), alert: e.message}
        format.json { render json: {:error=> e.message.to_s}, status: :unprocessable_entity }
      end
    end
  end

   # GET/bills/1/edit
  def edit
    @bill = Bill.find(params[:id])
  end

  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  api :POST, '/bills/split_bill.json', "Split a new bill."
  error :code => 401, :desc => "Unauthorized"
  param :bill_id, String, :desc => "Bill ID", :required => true
  param :unit_id, String, :desc => "Outlet ID", :required => true
  param :user_id, String, :desc => "User ID", :required => true
  param :split_type, String, :desc => "Split type. Values will be in any one of these: by_product, by_amount", :required => true
  param :split_details, String, :desc => "Bill split details JSON. Sample JSON (Split by product) : [{ 'bill_amount': '250.00', 'tax_amount': '25.00', 'discount': '0.00', 'grand_total':'275.00', 'product_details': [ { 'product_id':45, 'quantity':5, 'price': '150.00' }, { 'product_id':46, 'quantity':2, 'price': '100.00' } ] }, { 'bill_amount': '400.00', 'tax_amount': '40.00', 'discount': '0.00', 'grand_total':'440.00', 'product_details': [ { 'product_id':61, 'quantity':2, 'price': '100.00' }, { 'product_id':65, 'quantity':3, 'price': '300.00' } ] }]  . For split by amount just keep that 'product_details' key empty", :required => true
  description " API URL : http://dev.selfordering.com/bills/split_bill.json?device_id=YOTTO05"
  example "{'bill_amount':50.0,'created_at':'2015-08-05T11:17:20Z','deliverable_id':21,'deliverable_type':'Table','discount':0.0,'grand_total':57.0,'id':99,'order_sr_no':null,'status':'unpaid','tax_amount':7.0,'tax_details':null,'unit_id':5,'updated_at':'2015-08-05T11:17:20Z','user_id':1,'bill_splits':[],'orders':[{'billed':1,'cancel_cause':null,'consumer_id':4,'consumer_type':'User','created_at':'2015-08-05T11:17:17Z','delivary_date':'2015-08-05T16:34:08Z','deliverable_id':21,'deliverable_type':'Table','delivery_boy_id':null,'id':123,'order_sr_no':null,'order_status_id':2,'order_subtotal':57.0,'order_total_without_tax':50.0,'source':'fos','total_discount':0.0,'total_tax':7.0,'trash':0,'unit_id':5,'updated_at':'2015-08-05T11:17:20Z','user_id':null,'order_details':[{'bill_status':null,'cancel_cause':null,'created_at':'2015-08-05T11:17:17Z','customization_price':0.0,'discount':0.0,'id':197,'is_stock_debited':'yes','menu_product_id':209,'order_id':123,'parcel':1,'preferences':'','procurement_cost':40.0,'product_id':43,'product_name':'Tomato Soup','product_price':50.0,'quantity':1,'sort_id':2,'status':'approved','subtotal':57.0,'tax_amount':7.0,'tax_details':'[{\'tax_class_name\':\'simple 2\',\'tax_type\':\'simple\',\'tax_percentage\':\'14\',\'tax_amount\':7.0}]','trash':0,'unit_id':5,'unit_price_with_tax':57.0,'unit_price_without_tax':50.0,'updated_at':'2015-08-05T11:17:18Z','order_detail_combinations':[]}]}]}"
  formats ['json']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  
  def split_bill
    begin
      _split_details = JSON.parse(params[:split_details])
      ActiveRecord::Base.transaction do # Protective transaction block
        _split_details.each do |sd|
          BillSplit.create_split_bill(params[:bill_id],params[:unit_id],params[:user_id],params[:split_type],sd["bill_amount"],sd["tax_amount"],sd["discount"],sd["grand_total"],sd["product_details"])
        end
      end
      respond_to do |format|
        format.json { render json: @bill.to_json(:include => [{:bill_splits => {:include => :bill_split_products}}, {:orders => {:include => [:order_details => {:include => :order_detail_combinations}]}}, :payments, {:bill_tax_amounts => {:include => :tax_class}}] ) }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      respond_to do |format|
        format.json { render json: {:error=> e.message.to_s}, status: :unprocessable_entity }
      end
    end
  end

  def generate_bill
    @bill = Bill.find(params[:id])

    respond_to do |format|
      format.pdf { render :layout => false } # Add this line
    end
  end

  def get_bill_by_serial
    @bill = Bill.where("serial_no=?",params[:serial_no])
    respond_to do |format|
      format.json { render json: @bill[0].to_json(:include => [{:bill_splits => {:include => :bill_split_products}}, :payments, {:bill_tax_amounts => {:include => :tax_class}}, {:orders => {:include => [:order_details => {:include => [:product, :order_detail_combinations => {:include => {:menu_product_combination => {:include => :product}}}]}]}}])}
    end
  end

  private

  def set_module_details
    @module_id = "bills"
    @module_title = "Bills"
  end

  def set_bill
    @bill = Bill.find(params[:bill_id])
  end

  def bill_params
    {
      "unit_id"           => params[:unit_id],
      "serial_no"         => params[:serial_no],
      "pax"               => params[:pax],
      "biller_id"         => params[:biller_id].present? ? params[:biller_id] : params[:user_id],
      "biller_type"       => params[:biller_type].present? ? params[:biller_type].camelize : "User",
      "deliverable_id"    => params[:deliverable_id],
      "deliverable_type"  => params[:deliverable_type],
      "device_id"         => params[:device_id],
      "recorded_at"       => params[:recorded_at] || Time.now.utc,
      "remarks"           => (params[:discount].present? and params[:discount].to_f > 0) ? "" : params[:remarks],
      "bill_orders_attributes" => (JSON.parse(params[:order_ids])).map{ |x| {order_id: x['order_id']} },
      "bill_discounts_attributes" => (params[:discount].present? and params[:discount].to_f > 0) ? [{"discount_amount" => params[:discount], "remarks" => params[:remarks]}] : []
    }
  end
end
