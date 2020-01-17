class VendorsController < ApplicationController
  load_and_authorize_resource
  #Including required libraries
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  include StocksHelper
  include StockPurchasePaymentsHelper
  layout "material"

  before_filter :set_module_details

  # GET /vendors
  # GET /vendors.json
  def index
    # @vendors = Vendor.where(unit_id: current_user.unit_id )
    @vendors = params[:unit_id].present? ? Vendor.where(unit_id: params[:unit_id] ) : Vendor.where(unit_id: current_user.unit_id )
    @vendors = @vendors.vendor_like(params[:filter]) if params[:filter].present?
    smart_listing_create :vendors, @vendors, partial: "vendors/vendors_smartlist", default_sort: {id: "desc"}

    respond_to do |format|
      format.js # index.js.erb
      format.html # index.html.erb
      format.json { render json: @vendors }
    end
  end

  # GET /vendors/1
  # GET /vendors/1.json
  def show
    @vendor = Vendor.find(params[:id])
    @categories = Category.all
    @product_scope = @vendor.products 
    @product_scope = @product_scope.filter_by_product_type(params[:product_type]) if params[:product_type].present?
    @product_scope = @product_scope.filter_by_product_category(params[:product_category]) if params[:product_category].present?
    @product_scope = @product_scope.set_category(params[:category_id]) if params[:category_id].present?
    @product_scope = @product_scope.filter_by_string(params[:filter]) if params[:filter].present?
    @product_scope = @product_scope.filter_by_product_id(params[:product_id_filter]) if params[:product_id_filter].present?
    smart_listing_create :products, @product_scope, partial: "products/vendor_products_smartlist", default_sort: {id: "desc"}
    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.json { render json: @vendor }
    end
  end

  def payment_details
    @vendor = Vendor.find(params[:id])
    @purchase_scope = StockPurchase.received.by_vendor(params[:id])
    @total_amount = 0
    @paid_amount = 0
    @purchase_scope.each do |sp|
      if sp.total_amount.present?
        @total_amount += sp.total_amount
      end
      if sp.paid_amount.present?
        @paid_amount += sp.paid_amount
      end 
    end  
    smart_listing_create :vendor_purchases, @purchase_scope, partial: "vendors/vendor_purchase_order_smartlist",default_sort: {id: "desc"}
  	respond_to do |format|
	   format.html
	   format.js
	   format.csv{send_data payment_details_csv(@purchase_scope.order("id DESC")),filename:"vendor_payment_details_csv.csv"}
	end
  end

  def add_vendor_products
    @vendor = Vendor.find(params[:id]) 
    @categories = Category.all
    _vendor_products = @vendor.vendor_products.pluck(:product_id)
    @product_scope = Product.get_all
    @product_scope = @product_scope.product_not_in(_vendor_products) if _vendor_products.present?
    @product_scope = @product_scope.filter_by_product_type(params[:product_type]) if params[:product_type].present?
    @product_scope = @product_scope.filter_by_product_category(params[:product_category]) if params[:product_category].present?
    @product_scope = @product_scope.set_category(params[:category_id]) if params[:category_id].present?
    @product_scope = @product_scope.filter_by_string(params[:filter]) if params[:filter].present?
    smart_listing_create :products, @product_scope, partial: "products/product_checkbox_smartlist", default_sort: {id: "desc"}
 	
  end

  def allocate_product_to_vendor
    begin
      raise 'No Product checkbox selected' unless params[:products].present?
      ActiveRecord::Base.transaction do
        params[:products].each do |pro|
          _vendor_product = VendorProduct.create(:vendor_id=>params[:id],:product_id=>pro,:price=>params["price#{pro}"],:tax_group_id=>params["tax_group_id#{pro}"])
        end
      end  
      redirect_to vendor_path(params[:id]), notice: "Products successfully added to vendor" 
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to vendor_path(params[:id]), alert: e.message.to_s      
    end
  end

  def remove_vendor_product
    @vendor = Vendor.find(params[:id])
    _product = @vendor.vendor_products.by_product(params[:product_id]).first
    _product.destroy
    respond_to do |format|
      format.html{redirect_to vendor_path(params[:id]), notice: 'Product was successfully deleted.'}
      format.json {head:no_content}
    end
  end

  def edit_vendor_product
    @vendor = Vendor.find(params[:id])
    @vendor_product = @vendor.vendor_products.by_product(params[:product_id]).first
  end

  def update_vendor_product
    @vendor = Vendor.find(params[:id])
    @product = @vendor.vendor_products.by_product(params[:product_id]).first
    if @product.update_attributes(params[:vendor_product])
      respond_to do |format|
        format.html { redirect_to vendor_path(params[:id]), notice: 'Product Price successfully updated.' }
        format.json { head :no_content }
      end
    end   
  end

  # GET /vendors/new
  # GET /vendors/new.json
  def new
    @vendor = Vendor.new
    @unittypes = Unittype.all
    @current_user_unittypes = @current_user.unit.unittype
    @current_user_unit = @current_user.unit
    @sections = @current_user.unit.sections
    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @vendor }
    end
  end

  def get_selected_unittype
    require_unittype_id = params[:unittype_id]
    @current_user_unittype = @current_user.unit.unittype
    @current_user_unit = @current_user.unit

    if require_unittype_id.to_i == 1
      units = []
      if @current_user_unittype.id == 1
        units.push(@current_user.unit)
      end
    elsif require_unittype_id.to_i == 2
      units = []
      if @current_user_unittype.id == 1
        units = @current_user.unit.children
      elsif @current_user_unittype.id.to_i == 2
        units.push(@current_user.unit)
      end
    elsif require_unittype_id.to_i == 3
      units = []
      if @current_user_unittype.id == 1
        dc_units = @current_user.unit.children
        dc_units.each do |dcu|
          dcu.children.each do |ol|
           units.push(ol)
          end
        end
      elsif @current_user_unittype.id.to_i == 2
        units = @current_user.unit.children 
      end
    end

    respond_to do |format|
      format.json { render :json => units}
    end
  end

  # GET /vendors/1/edit
  def edit
    @vendor = Vendor.find(params[:id])
    @unittypes = Unittype.all
    @current_user_unittypes = @current_user.unit.unittype
    @current_user_unit = @current_user.unit
  end

  # POST /vendors
  # POST /vendors.json
  def create
    @vendor = Vendor.new(params[:vendor])

    respond_to do |format|
      if @vendor.save
        format.html { redirect_to vendors_path, notice: 'Vendor was successfully created.' }
        format.json { render json: @vendor, status: :created, location: @vendor }
        format.js
      else
        format.html { render action: "new" }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_vendor
    @vendor = Vendor.new(params[:vendor])

    respond_to do |format|
      if @vendor.save
        format.html { redirect_to vendors_path, notice: 'Vendor was successfully created.' }
        format.json { render json: @vendor, status: :created, location: @vendor }
        format.js
      else
        format.html { render action: "new" }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /vendors/1
  # PUT /vendors/1.json
  def update
    @vendor = Vendor.find(params[:id])
    respond_to do |format|
      if @vendor.update_attributes(params[:vendor])
        format.html { redirect_to vendors_path, notice: 'Vendor was successfully updated.' }
        format.json { head :no_content }
        format.js
      else
        format.html { render action: "edit" }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def update_vendor
    @vendor = Vendor.find(params[:id])
    @unittypes = Unittype.all
    @current_user_unittypes = @current_user.unit.unittype
    respond_to do |format|
      if @vendor.update_attributes(params[:vendor])
        format.html { redirect_to vendors_path, notice: 'Vendor was successfully updated.' }
        format.json { head :no_content }
        format.js
      else
        format.html { render action: "edit" }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /vendors/1
  # DELETE /vendors/1.json
  def destroy
    @vendor = Vendor.find(params[:id])
    @vendor.destroy

    respond_to do |format|
      format.html { redirect_to vendors_url, notice: 'Vendor was successfully deleted.' }
      format.json { head :no_content }
      format.js
    end
  end

  def import
    begin
      ActiveRecord::Base.transaction do
        Vendor.import(params[:file])
        redirect_to :back, notice: 'vendor was successfully imported.'
      end      
    rescue Exception => e
      flash[:error] = e.message
      redirect_to :back
    end
  end

  private
  def set_module_details
    @module_id = "vendors"
    @module_title = "Vendors"
  end  

  def payment_details_csv(po_scope)
	 	CSV.generate do |csv|
      csv<<["ID","Purchase Order","PO status","Payment Status","Total Amount","Due Amount", "GRN no","Invoice No","Invoice Date","Invoice Amount","Send at","Received at","Payment_amount","Payment mode","Reference no","Date","Payment_date"]
	   po_scope.each do |obj|
	     id = obj.id
	     po = "#(#{obj.purchase_order_id})""#{obj.purchase_order.name}"
	     payment_status = obj.payment_status
	     paid_amount = obj.paid_amount? ? obj.paid_amount : 0
	     due_amount = obj.total_amount - paid_amount if obj.total_amount.present?
	     stock_purchase_total = stock_purchase_total_price(obj.id)
	     grn = obj.grn_no.present? ? obj.grn_no : '-'
	     invoice_no = obj.invoice_no.present? ? obj.invoice_no : '-'
	     invoice_date = obj.invoice_date.present? ? obj.invoice_date : '-'
	     invoice_amount = obj.invoice_amount.present? ? obj.invoice_amount : '-'
	     created_at = obj.created_at.strftime("%d-%m-%Y, %I:%M %p") 
	     updated_at = obj.updated_at.strftime("%d-%m-%Y, %I:%M %p") 
	     po_status = get_po_status(obj)
	     if  obj.stock_purchase_payments.present?
	       obj.stock_purchase_payments.each do |stock_purchase_payment|
          csv<<[id,po,po_status,payment_status,stock_purchase_total,due_amount,grn,invoice_no,invoice_date,invoice_amount,created_at,updated_at,stock_purchase_payment.payment_amount.to_f.round(2),stock_purchase_payment.payment_mode.humanize,stock_purchase_payment.details,stock_purchase_payment.created_at,stock_purchase_payment.payment_date]
	       end
	     else
          csv<<[id,po,po_status,payment_status,stock_purchase_total,due_amount,grn,invoice_no,invoice_date,invoice_amount,created_at,updated_at]
	     end
	   end
	 	end
	end
	
  def get_po_status(obj)
   if obj.cancellation_status.present?
    "#{obj.cancellation_status}"
   else
    "Received"
   end
 	end
end









