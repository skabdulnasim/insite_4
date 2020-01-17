class HomeController < ApplicationController
  layout :resolve_layout
  load_and_authorize_resource
  include ApplicationHelper

  before_filter :set_timerange, only: [:get_chart_data,:get_map_data]
  before_filter :set_module_details
  before_filter :build_units_array, only: [:get_chart_data,:get_map_data,:get_inventory_data]
  before_filter :set_common_dashboard_data, only: [:get_chart_data,:get_map_data]



  def index
    current_user_id=get_current_user_id()
    @current_user = UserManagement::get_current_user(current_user_id)
    current_user_unit_id = @current_user.unit_id
    @main_arr = {}
    if current_user_unit_id.nil?
      # @root = Unit.find(:all, :conditions => ['unit_parent =?',nil])
      @root = Unit.where(:unit_parent => nil)
    else
      # @root = Unit.find(:all, :conditions => ['id =?', current_user_unit_id])
      @root = Unit.where(:id => current_user_unit_id)
    end
    @main_arr = @root[0].to_node
    p @main_arr
    respond_to do |format|
      format.html
      format.json{render json: @main_arr}

    end
  end

  def welcome
    
    # @latest_orders = Order.check_order_unit(current_user.unit_id).order("created_at DESC").first(10)
    respond_to do |format|
      format.js
      format.html # show.html.erb
    end
  end

  def dashboard
    @final_arr = {}
    @all_categories = Category.all
    @max_unittype_priority = Unittype.order('unit_type_priority DESC').first
    if @max_unittype_priority
      # @cities = Unit.find(:all, :select => 'DISTINCT city', :conditions=> {unittype_id: @max_unittype_priority.id})
      @cities = Unit.where(:unittype_id => @max_unittype_priority.id).select("DISTINCT(city)")
    end
    @get_menu_products = MenuManagement::get_menu_products()
    @order_sources = Order.uniq.pluck(:source)
    @total_details_arr = Array.new
    menu_products = MenuManagement::get_menu_products()
    menu_products.each do |menu_product|
      total_details = {}
      total_details['product_id'] = menu_product[:name]
      total_sell = OrderManagement::get_total_sell_by_menu_product_by_all(menu_product[:id])
      total_details['total_sale'] = total_sell[:total_sell]
      total_details['total_sale_quantity'] = total_sell[:total_sell_quantity]
      @total_details_arr.push total_details
    end
    ######### For inventory product stock details... #############
    inventory_products = StoreManagement::get_products_stock_details_in_all_units()
    @main_arr1 = inventory_products.sort_by { |k, v| -k[:current_stock] }[0..9].flatten
    @main_arr = inventory_products
    @final_arr[:product_stock] = @main_arr1
    _menu_product_prices = @total_details_arr.sort_by { |k, v| k[:total_sale] }[0..9].flatten
    _menu_product_quantity = @total_details_arr.sort_by { |k, v| k[:total_sale_quantity] }[0..9].flatten
    @final_arr[:menu_product_sales_price] = _menu_product_prices
    @final_arr[:menu_product_sales_quantity] = _menu_product_quantity
    respond_to do |format|
      format.html #index.html
      format.json{render json: @final_arr}
    end

  end

  def unit_tree
    product_id = params[:product_id]
    @current_user_id=get_current_user_id()
    @current_user = UserManagement::get_current_user(@current_user_id)
    current_user_unit_id = @current_user.unit_id
    if current_user_unit_id.nil?
      _root_unit = Unit.where(:unit_parent => nil).first
    else
      _root_unit = Unit.where(:id => current_user_unit_id).first
    end
    _root_unit_id = (_root_unit.id).to_i
    _unit_stock =  StoreManagement::get_stock_details(product_id,_root_unit_id)
    _root_childs = BranchManagement::get_unit_childs(product_id,_root_unit_id)
    _tree_hash = {}
      _attr_hash = {}
      _attr_hash[:id] = _root_unit.id
    _tree_hash[:unit_id] = _root_unit.id
    _tree_hash[:unit_name] = _root_unit.unit_name
    _tree_hash[:unit_stock] = _unit_stock
    _tree_hash[:children] = _root_childs
    respond_to do |format|
      #format.html #
      format.json{render json: _tree_hash}
    end
  end

  def get_stock_info
    @below_limit = 0
    @total_stock = 0
    @current_user_id=get_current_user_id()
    @current_user = UserManagement::get_current_user(@current_user_id)
    unit_id = @current_user.unit_id
    all_stores = Store.unit_stores(unit_id).physical.primary #New Code
    all_stores.each do |as|
      @all_products = Product.all
      @all_products.each do |ap|

        @total_stock = StockUpdate.current_stock(as.id,ap.id)

        if @total_stock.nil?
          @below_limit = @below_limit + 1
        end
      end
    end
    respond_to do |format|
      format.json{render json: @below_limit}
    end
  end

  ############ Get products of a given category...
  def get_products
    category_id = params[:category_id]
    all_products = Product.where(:category_id => category_id)
    respond_to do |format|
      format.json{render json: all_products}
    end
  end

  #Dashboard V2 Codes
  def get_chart_data
    order_src = Order.select("count(id) as value, source as label").group("source").set_unit_in(@unit_arr).by_recorded_at(@from_datetime,@to_datetime)
    sale_dates =  @sales_historical_data.map{|x| x.date}
    sale_amounts =  @sales_historical_data.map{|q| q.total_price.to_f}
    cost_amounts =  @cost_historical_data.map{|y| (y.proc_cost.to_f + y.custom_cost.to_f)}
    order_counts =  @orders_historical_data.map{|z| z.order_count.to_f}
    order_dates =  @orders_historical_data.map{|m| m.date}
    respond_to do |format|
      format.json{ render json: {
        :sales=>{:sales_today =>@sales_today, :daily_sale_amounts =>sale_amounts, :daily_sale_average =>(sale_amounts.sum / sale_amounts.size.to_f), :sale_dates =>sale_dates},
        :orders=>{:orders_today =>@orders_today, :order_average =>(order_counts.sum / order_counts.size.to_f), :order_sources =>order_src, :order_counts => order_counts, :order_dates => order_dates},
        :costs=>{:cost_today =>(@proc_cost_today.to_f + @cust_cost_today.to_f).round(2), :daily_cost_average =>(cost_amounts.sum / cost_amounts.size.to_f),:daily_costs => cost_amounts}}
      }
    end
  end

  def get_map_data
    _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    _unit = Unit.find(_unit_id)
    @unit_details = _unit.unit_detail.options
    _daily_target = @unit_details.present? ? @unit_details[:daily_sales_target] : 0
    unit_sales_data = Bill.select("unit_id, sum(grand_total) as total_sales").group("unit_id").set_unit_in(@unit_arr).by_recorded_at(@from_datetime,@to_datetime)
    units = @unit_arr.map{|u| (Unit.find(u))}
    sale_units =  unit_sales_data.map{|x| (Unit.find(x.unit_id))}
    sale_amounts =  unit_sales_data.map{|q| q.total_sales.to_f}
    cost_amounts =  @cost_historical_data.map{|y| (y.proc_cost.to_f + y.custom_cost.to_f)}
    msp_by_price = OrderDetail.most_sold_items_by_price.set_unit_in(@unit_arr).by_recorded_at(@from_datetime,@to_datetime).valid_item.first(10)
    msp_by_qnantity = OrderDetail.most_sold_items_by_quantity.set_unit_in(@unit_arr).by_recorded_at(@from_datetime,@to_datetime).valid_item.first(10)
    # unit_data[:most_sold_products] = Order.most_sold_items.check_order_unit(@unit_id).last_month.first(10)
    respond_to do |format|
      format.json{render json: {
        :units => units,
        :unit_data=>{:sales_today=>@sales_today, :sales_history=>@sales_historical_data, :orders_today=>@orders_today, :order_history=>@orders_historical_data, :cost_today=> (@proc_cost_today.to_f + @cust_cost_today.to_f), :cost_history =>cost_amounts, :daily_sales_target =>_daily_target},
        :unit_sales_data=>{:units=>sale_units, :sale_amounts=>sale_amounts, :most_sold_items_by_quantity => msp_by_qnantity, :most_sold_items_by_price => msp_by_price}}
      }
    end
  end

  def get_inventory_data
    unit_stores = Store.set_unit_in(@unit_arr)
    store_ids = unit_stores.map{|q| q.id}
    stock_consumption = Stock.set_store_in(store_ids).type_debit.check_stock_date(params[:from_date], params[:to_date])
    respond_to do |format|
      format.json{render json: {
        :stock_debits => stock_consumption
      }}
    end
  end
  private

  def resolve_layout
    case action_name
    when "welcome"
      "material"
    else
      "application"
    end
  end

  def set_module_details
    @module_id = "dashboard"
    @module_title = "Dashboard"
  end

  def build_units_array
    @unit_arr = Array.new
    params[:units].present? ? params[:units].map{|x| @unit_arr.push(x)} : @unit_arr.push(current_user.unit_id)
  end

  def set_common_dashboard_data
    @sales_today = Bill.set_unit_in(@unit_arr).by_recorded_at(@today_from_datetime,@today_to_datetime).sum(:grand_total)
    @orders_today = Order.by_recorded_at(@today_from_datetime,@today_to_datetime).set_unit_in(@unit_arr).count
    @proc_cost_today = OrderDetail.set_unit_in(@unit_arr).by_recorded_at(@today_from_datetime,@today_to_datetime).sum("material_cost")
    @cust_cost_today = OrderDetail.set_unit_in(@unit_arr).by_recorded_at(@today_from_datetime,@today_to_datetime).sum("customization_price * quantity")
    @sales_historical_data = Bill.select("date(recorded_at) as date, sum(grand_total) as total_price").group("date(recorded_at)").set_unit_in(@unit_arr).order("date(recorded_at)").by_recorded_at(@from_datetime,@to_datetime)
    @orders_historical_data = Order.select("date(recorded_at) as date, count(id) as order_count").group("date(recorded_at)").set_unit_in(@unit_arr).order("date(recorded_at)").by_recorded_at(@from_datetime,@to_datetime)
    @cost_historical_data = OrderDetail.select("date(recorded_at) as date, sum(material_cost) as proc_cost, sum(customization_price * quantity) as custom_cost").group("date(recorded_at)").set_unit_in(@unit_arr).order("date(recorded_at)").by_recorded_at(@from_datetime,@to_datetime)
  end

  # def get_child_units(_root_unit_id,unit_arr)
  #   _child_units = Unit.find(:all, :conditions =>["unit_parent=?",_root_unit_id])
  #   _child_units.each do |cu|
  #     unit_arr.push(cu)
  #     get_child_units(cu.id,unit_arr)
  #   end
  #   return unit_arr
  # end

end
