class StoresController < ApplicationController
  load_and_authorize_resource

  layout "material"

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  before_filter :set_module_details
  before_filter :get_current_user, only: [:index, :create, :show, :edit, :update, :destroy, :kitchen_store, :return_store]
  before_filter :set_store_by_id, only: [:show, :edit, :update, :destroy, :kitchen_store, :reports, :return_store]
  before_filter :validate_store_ownership, only: [:show, :edit, :update, :destroy, :kitchen_store, :return_store]
  before_filter :get_store_generic_smartlists, only: [:show, :kitchen_store, :return_store]
  before_filter :set_timerange, only: [:reports, :return_store]
  before_filter :manage_production_status


  # GET /stores
  # GET /stores.json
  def index
    if params[:id].present?
      @stores = Unit.find(params[:id]).stores
    elsif params[:ids].present?
      values = params[:ids][0].split(",")
      @stores = Store.set_unit_in(values)
    elsif params[:transfer_type].present?
      @stores = Store.order('id asc')
      @stores = @stores.by_transfer_type(params[:transfer_type], params[:store_id], current_user.unit_id) if params[:transfer_type].present? and current_user.present?
    elsif current_user.present?
      if current_user.stores.present?
        @stores = current_user.stores
      else  
        @stores = current_user.unit.stores
      end  
    else
      @stores = Store.all  
    end
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @stores }
    end
  end

  # GET /stores/1
  # GET /stores/1.json
  def show
    @packages = Package.where("production_status != ?", '0')
    @business_types = Product::BUSINESS_TYPE
    @product_stocks = @store.stocks.select("product_id , sum(available_stock) as stock").group(:product_id)
    @store_rack = @store.store_racks.build
    @bin = @store_rack.bins.build
    @vendors = Vendor.where(:unit_id => @current_user.unit_id).order("name ASC")
    if @store.store_type == 'kitchen_store'
      msg = notice.present? ? notice : alert
      redirect_to kitchen_store_store_path(@store), notice: msg
      return false
    end
    if @store.store_type == 'return_store'
      msg = notice.present? ? notice : alert
      redirect_to return_store_store_path(@store), notice: msg
      return false
    end
    @store_purchase_orders = @store.purchase_orders
    @store_purchase_orders = @store_purchase_orders.where(:id=>params[:po_id_filter]) if params[:po_id_filter].present?
    smart_listing_create :store_purchase_orders, @store_purchase_orders, partial: "stores/store_purchase_order_smartlist",default_sort: {created_at: "desc"}
    po_scope = @store.stock_purchases
    po_scope = po_scope.set_status(params[:po_status]) if params[:po_status]
    po_scope = po_scope.where(:purchase_order_id=>params[:send_rec_po_id_filter]) if params[:send_rec_po_id_filter].present?
    smart_listing_create :stock_purchase, po_scope, partial: "stores/purchase_smartlist",default_sort: {created_at: "desc"}
    smart_listing_create :store_requisitions, @store.store_requisitions, partial: "stores/store_requisition_smartlist",default_sort: {created_at: "desc"}
    smart_listing_create :recv_requisitions, @store.store_requisition_logs, partial: "stores/requisition_recv_smartlist",default_sort: {created_at: "desc"}
    smart_listing_create :sent_requisitions, @store.sent_requisitions, partial: "stores/requisition_sent_smartlist",default_sort: {created_at: "desc"}
    smart_listing_create :store_racks, @store.store_racks, partial: "stores/store_racks_smartlist",default_sort: {created_at: "desc"}
    smart_pos = @store.smart_pos
    smart_listing_create :smart_purchase_orders, smart_pos, partial: "purchase_orders/smart_purchase_order_smartlist",default_sort: {id: "desc"}
    smart_listing_create :warehouse, @store.warehouse_meta.order("id ASC"), partial:"stores/warehouse_smartlist",default_sort: {id: "asc"}
    smart_listing_create :product_stock,@product_stocks, partial:"stores/product_stock_smartlist" ,page_sizes: [15]
    respond_to do |format|
      format.js
      format.html # show.html.erb
    end
  rescue Exception => e
    Rscratch::Exception.log e,request
    # redirect_to stores_path, alert: e.message
  end

  def kitchen_store
    begin
      @vehicles = Vehicle.unit_vehicles(current_user.unit_id)
      @business_types = Product::BUSINESS_TYPE
      smart_listing_create :kitchen_productions, @store.stock_productions, partial: "stores/kitchen_production_smartlist",default_sort: {created_at: "desc"}
      _kitchen_audit_scope = @store.kitchen_production_audits.unique_audits
      smart_listing_create :kitchen_production_audits, _kitchen_audit_scope, partial: "stores/kitchen_production_audit_smartlist"
      smart_listing_create :store_requisitions, @store.store_requisitions, partial: "stores/store_requisition_smartlist",default_sort: {created_at: "desc"}
      smart_listing_create :recv_requisitions, @store.store_requisition_logs, partial: "stores/requisition_recv_smartlist",default_sort: {created_at: "desc"}
      smart_listing_create :sent_requisitions, @store.sent_requisitions, partial: "stores/requisition_sent_smartlist",default_sort: {created_at: "desc"}
      respond_to do |format|
        format.js
        format.html # show.html.erb
      end
    end
  end

  def return_store
    begin
      @site_title = AppConfiguration.get_config_value('site_title')
      @business_types = Product::BUSINESS_TYPE
      @stocks = ReturnItem.by_store(params[:id]).order("created_at desc")
      #@stocks = @stocks.available if @stocks.present?
      smart_listing_create :return_items, @stocks, partial: "stores/return_item_smartlisting",default_sort: {created_at: "desc"}
      respond_to do |format|
        format.js
        format.html # show.html.erb
      end
    # rescue Exception => e
    #   redirect_to stores_path, alert: e.message
    end
  end

  # GET /stores/new
  # GET /stores/new.json
  def new
    @store = Store.new
    @child_roles = Role.set_role_in(nested_child_roles(current_user.role.id))
    @users = @current_user.unit.users.all
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @store }
    end
  end

  # GET /stores/1/edit
  def edit
    @child_roles = Role.set_role_in(nested_child_roles(current_user.role.id))
    @users = @current_user.unit.users.all
  end

  # POST /stores
  # POST /stores.json
  def create
    @store = Store.new(params[:store])
    @store[:unit_id] = @current_user.unit_id
    respond_to do |format|
      if @store.save
        format.html { redirect_to add_products_store_path(@store.id), notice: 'Store was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /stores/1
  # PUT /stores/1.json
  def update
    respond_to do |format|
      if @store.update_attributes(params[:store])
        format.html { redirect_to add_products_store_path(@store), notice: 'Store was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /stores/1
  # DELETE /stores/1.json
  def destroy
    @store.destroy
    respond_to do |format|
      format.html { redirect_to stores_url, notice: 'Store was successfully deleted.' }
    end
  end

  def reports
    @store = Store.find(params[:id])
    #@pro_scope = Product.get_all
    @pro_scope = @store.products.present? ? @store.products : Product.get_all
    @pro_scope = @pro_scope.filter_by_string(params[:product_filter]) if params[:product_filter]
    @pro_scope = @pro_scope.check_stock_status(@store.id,params[:stock_filter],current_user.unit_id) if params[:stock_filter]
    @pro_scope = @pro_scope.set_category(params[:category]) if params[:category]
    smart_listing_create :reports, @pro_scope, partial: "stores/report_smartlist",default_sort: {name: "asc"}
    respond_to do |format|
      format.js
      format.html # show.html.erb
      format.pdf { render :layout => false }
      format.csv { send_data Product.stock_report_to_csv(@store.id,@pro_scope,@from_datetime,@to_datetime) }
      format.xls #{ send_data @pro_scope.to_csv(col_sep: "\t") }
    end
  end

  def add_products
    @store = Store.find(params[:id])
    @categories = Category.all
    _store_products = @store.store_products.pluck(:product_id)
    @product_scope = current_user.unit.products.present? ? current_user.unit.products : Product.get_all
    if current_user.unit.products.present?
      @product_scope = @product_scope.product_not_in_unit(_store_products) if _store_products.present?
    else
      @product_scope = @product_scope.product_not_in(_store_products) if _store_products.present?
    end  
    @product_scope = @product_scope.filter_by_product_type(params[:product_type]) if params[:product_type].present?
    @product_scope = @product_scope.filter_by_product_category(params[:product_category]) if params[:product_category].present?
    @product_scope = @product_scope.set_category(params[:category_id]) if params[:category_id].present?
    @product_scope = @product_scope.filter_by_string(params[:filter]) if params[:filter].present?
    smart_listing_create :products, @product_scope, partial: "products/store_products_checkbox_smartlist", default_sort: {id: "desc"}
  end

  def allocate_product
    begin
      raise 'No Product checkbox selected' unless params[:products].present?
      ActiveRecord::Base.transaction do
        params[:products].each do |pro|
          _store_product = StoreProduct.create(:store_id=>params[:id],:product_id=>pro)
        end
      end
      redirect_to store_path(params[:id]), notice: "Products successfully added to store"
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to store_path(params[:id]), alert: e.message.to_s
    end
  end
  # def get_productions
  #   puts 'getting the  production details'
  # end
  def manage_production_status
    if params[:id].present?
      @store = Store.find(params[:id])
      if @store.stock_productions.present?
        @store.stock_productions.each do  |production|
          if(production.status != '2')
            production.stock_production_metas.each do |production_meta|
              status_array=[]
              production_meta.stock_production_meta_processes.each do |production_process|
                status_array.push(production_process.status)
              end
              if (status_array.count('initialize') == status_array.length) and production.status != "2"
                production.update_attributes(status: "1")
              else
                if (status_array.count('done') == status_array.length)
                  production.update_attributes(status: "2")
                else
                  if status_array.include? "start"
                    production.update_attributes(status: "3")
                   else 
                    production.update_attributes(status: "4")
                   end
                end
              end
            end
            
          else
          end
        end
      end
    end
  end
  
  private
  def set_module_details
    @module_id = "inventory"
    @module_title = "Inventory"
    @child_role_ids = []
  end

  def set_store_by_id
    @store = Store.find(params[:id])
  end

  def validate_store_ownership
    if @current_user.unit_id != @store.unit_id
      redirect_to oops_index_path, notice: 'You are not authorised to access this resource'
    end
  end

  def get_store_generic_smartlists
    @store = Store.find(params[:id])
    @boxings  = Boxing.order('created_at desc')
    @all_products = @store.products.present? ? @store.products : Product.get_all
    pro_scope = @all_products
    pro_scope = pro_scope.check_stock_status(@store.id,params[:stock_filter],@current_user.unit_id) if params[:stock_filter]
    pro_scope = pro_scope.filter_by_string(params[:filter]) if params[:filter]
    pro_scope = pro_scope.set_category(params[:category]) if params[:category]
    pro_scope = pro_scope.filter_by_sku(pro_scope,params[:sku_filter],params[:id]) if params[:sku_filter].present?
    pro_scope = pro_scope.filter_by_product_id(params[:product_id_filter]) if params[:product_id_filter].present?
    smart_listing_create :products, pro_scope, partial: "stores/product_smartlist",default_sort: {name: "asc"}
    _trans_cr_scope = @store.stock_credit_transfers
    _trans_cr_scope = _trans_cr_scope.set_transfer_status(params[:credit_status]) if params[:credit_status]
    smart_listing_create :transfer_credits, _trans_cr_scope, partial: "stores/transfer_cr_smartlist",default_sort: {created_at: "desc"}
    _trans_db_scope = @store.stock_debit_transfers
    _trans_db_scope = _trans_db_scope.set_transfer_status(params[:debit_status]) if params[:debit_status]
    smart_listing_create :transfer_debits, _trans_db_scope, partial: "stores/transfer_db_smartlist",default_sort: {created_at: "desc"}
    smart_listing_create :stock_audits, @store.stock_audits, partial: "stores/stock_audit_smartlist",default_sort: {created_at: "desc"}
    smart_listing_create :initial_state, @store.simos.initial, partial: "stores/initial_states_smartlist", default_sort: {created_at: "desc"} 
    smart_listing_create :process_state, @store.simos.processed, partial: "stores/processed_states_smartlist", default_sort: {created_at: "desc"} 
    smart_listing_create :finish_state, @store.simos.finished, partial: "stores/finished_states_smartlist", default_sort: {created_at: "desc"}
    smart_listing_create :boxings, @boxings, partial: "boxings/boxings_smartlist"
  end

  def inventory_dashboard
    
  end

  def nested_child_roles(role_id)
    # _child_role_ids = []
    _child_roles = Role.child_roles(role_id)
    if _child_roles.present?
      _child_roles.each do |cr|
        @child_role_ids.push cr.id
        nested_child_roles(cr)
      end
    end
    @child_role_ids
  end


end
