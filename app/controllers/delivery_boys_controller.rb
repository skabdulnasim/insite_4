class DeliveryBoysController < ApplicationController

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  layout "material"
  include DeliveryBoysHelper
  before_filter :set_module_details

  # GET /delivery_boys
  # GET /delivery_boys.json
  def index
    if params[:unit_id]
      current_unit = Unit.find(params[:unit_id])
    else
      current_unit = Unit.find(current_user.unit_id)
    end
    
    @delivery_boys = current_unit.delivery_boys
    respond_to do |format|
      format.json { render json: @delivery_boys }
      format.html # index.html.erb
      
    end
  end

  # GET /delivery_boys/1
  # GET /delivery_boys/1.json
  def show
    @delivery_boy = DeliveryBoy.find(params[:id])
    @orders       = @delivery_boy.orders
    @orders       = @orders.orders_assigned_delivery_boy(@delivery_boy.id)
    @returns       = @delivery_boy.return_items
    @current_unit = Unit.find(current_user.unit_id)

    smart_listing_create :assigned_orders, @orders, partial: "delivery_boys/assigned_orders_smartlist"
    smart_listing_create :assigned_return_items, @returns, partial: "delivery_boys/assigned_return_items_smartlist"

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @delivery_boy }
      format.js
    end
  end

  # GET /delivery_boys/new
  # GET /delivery_boys/new.json
  def new
    @delivery_boy = DeliveryBoy.new
    @accounts = Account.all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @delivery_boy }
    end
  end

  # GET /delivery_boys/1/edit
  def edit
    @delivery_boy = DeliveryBoy.find(params[:id])
    @accounts = Account.all
    @assigned_current_delivery_boy = @delivery_boy.delivery_boys_units.all
  end

  # POST /delivery_boys
  # POST /delivery_boys.json
  def create
    @accounts = Account.all
    @delivery_boy = DeliveryBoy.new(params[:delivery_boy])
    DeliveryBoy.transaction do
      respond_to do |format|
        if @delivery_boy.save
          if DeliveryBoysUnit.save_assign_unit(params[:unit_id],@delivery_boy.id)
            format.html { redirect_to @delivery_boy, notice: 'Delivery boy was successfully created.' }
            format.json { render json: @delivery_boy, status: :created, location: @delivery_boy }
          end
        else
          format.html { render action: "new" }
          format.json { render json: @delivery_boy.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PUT /delivery_boys/1
  # PUT /delivery_boys/1.json
  def update
    @accounts = Account.all
    @delivery_boy = DeliveryBoy.find(params[:id])
    DeliveryBoy.transaction do
      respond_to do |format|
        if @delivery_boy.update_attributes(params[:delivery_boy])
          if DeliveryBoysUnit.save_assign_unit(params[:unit_id],@delivery_boy.id)
            format.html { redirect_to @delivery_boy, notice: 'Delivery boy was successfully updated.' }
            format.json { head :no_content }
          end
        else
          format.html { render action: "edit" }
          format.json { render json: @delivery_boy.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /delivery_boys/1
  # DELETE /delivery_boys/1.json
  def destroy
    @delivery_boy = DeliveryBoy.find(params[:id])
    @delivery_boy.destroy

    respond_to do |format|
      format.html { redirect_to delivery_boys_url , notice: 'Delivery boy was successfully Deleted.' }
      format.json { head :no_content }
    end
  end
  def assign_unit
    @accounts = Account.all
    @delivery_boy = DeliveryBoy.find(params[:id])
    @assign_unit = DeliveryBoysUnit.new
    @assigned_current_delivery_boy = @delivery_boy.delivery_boys_units.all
    
  end
  def create_assign_unit
    respond_to do |format|
      if DeliveryBoysUnit.save_assign_unit(params[:unit_id],params[:id])
        format.html { redirect_to delivery_boys_path, notice: 'Delivery Boy Assigned to Unit successfully.' }
        #format.json { render json: @assign_unit, status: :created, location: @printer }
      else
        format.html { redirect_to delivery_boys_path, notice: 'Selected Options not Saved.Please try again.' }
        #format.json { render json: @assign_unit.errors, status: :unprocessable_entity }
      end
    end
  end
  def assign_order
    @current_unit = Unit.find(current_user.unit_id)
    @delivery_boys = @current_unit.delivery_boys
    orders = Order.by_trash(0).orders_by_unit_in_date(current_user.unit_id).billed? #Order.orders_by_unit(current_user.unit_id)
    # returns = ReturnItem.unit_return_dboy(current_user.unit_id)
    # smart_listing_create :dboy_returns, returns, partial: "orders/dboy_returns_smartlist", default_sort: {created_at: "desc"}
    smart_listing_create :dboy_orders, orders, partial: "orders/dboy_orders_smartlist", default_sort: {delivary_date: "desc"}
  end

  def assign_return
    @current_unit = Unit.find(current_user.unit_id)
    @delivery_boys = @current_unit.delivery_boys
    returns = ReturnItem.unit_return_dboy(current_user.unit_id).joins(:order).merge(Order.by_deliverable_type('Address'))
    smart_listing_create :dboy_returns, returns, partial: "orders/dboy_returns_smartlist", default_sort: {created_at: "desc"}
  end
  
  def create_assign_order
    
    if params[:data_set].nil?
      data = params[:data]
    else
      data_params = JSON.parse(params[:data_set])
      data_set = Hash.new
      data_set[data_params["delivery_boy_id"]] = data_params["order_ids"]
      require 'json'
      data = data_set.to_json
    end
    
    begin
      raise 'Orders Or Delivery Boys Not selected .' if data.nil?
      ActiveRecord::Base.transaction do # Protective transaction block
        Order.save_assign_order(data)
      end
    rescue Exception => e
      respond_to do |format|
        format.json { render :json => {:error=> e.message}  }
      end      
    else
      respond_to do |format|
        format.json { render :json => {:success=> "Delivery Boy Assigned to Orders successfully."}  }
      end       
    end
    # respond_to do |format|
    #   if Order.save_assign_order(params[:data])
    #     format.json { render json: {message: 1} }
    #     #format.html { redirect_to delivery_boys_path, notice: 'Delivery Boy Assigned to Order successfully.' }
        
    #   else
    #     #format.html { redirect_to delivery_boys_path, notice: 'Selected Options not Saved.Please try again.' }
    #     format.json { render json: {message: 0} }
    #   end
    # end
  end

  def create_assign_return
    
    if params[:data_set].nil?
      data = params[:data]
    else
      data_params = JSON.parse(params[:data_set])
      data_set = Hash.new
      data_set[data_params["delivery_boy_id"]] = data_params["return_ids"]
      require 'json'
      data = data_set.to_json
    end
    
    begin
      raise 'Returns Or Delivery Boys Not selected .' if data.nil?
      ActiveRecord::Base.transaction do # Protective transaction block
        ReturnItem.save_assign_return(data)
      end
    rescue Exception => e
      respond_to do |format|
        format.json { render :json => {:error=> e.message}  }
      end      
    else
      respond_to do |format|
        format.json { render :json => {:success=> "Delivery Boy Assigned to Returns successfully."}  }
      end       
    end
    # respond_to do |format|
    #   if Order.save_assign_order(params[:data])
    #     format.json { render json: {message: 1} }
    #     #format.html { redirect_to delivery_boys_path, notice: 'Delivery Boy Assigned to Order successfully.' }
        
    #   else
    #     #format.html { redirect_to delivery_boys_path, notice: 'Selected Options not Saved.Please try again.' }
    #     format.json { render json: {message: 0} }
    #   end
    # end
  end

  def cancel_assigned_order
    begin
      raise 'Selected Options not Saved.Please try again.' if params[:data].nil?
      ActiveRecord::Base.transaction do # Protective transaction block
        Order.cancel_assigned_order(params[:data])
      end
    rescue Exception => e
      respond_to do |format|
        format.json { render :json => {:error=> e.message}  }
      end      
    else
      respond_to do |format|
        format.json { render :json => {:success=> "Assigned orders cancelled successfully."}  }
      end       
    end
    # respond_to do |format|
    #   if Order.cancel_assigned_order(params[:data])
    #     format.html { redirect_to delivery_boys_path, notice: 'Cancel Assigned Order successfully.' }
    #     format.json { render json: {message: 1} }
    #   else
    #     format.html { redirect_to delivery_boys_path, notice: 'Selected Options not Saved.Please try again.' }
    #     format.json { render json: {message: 0} }
    #   end
    # end
  end

  def cancel_assigned_return
    return_ids = params[:return_ids]
    return_ids.each do |return_id|
      @return = ReturnItem.find(return_id)
      @return = @return.update_attribute(:delivery_boy_id, nil)
    end
    respond_to do |format|
      format.json { render :json => {:success=> "Assigned return items cancelled successfully."}  }
    end
  end

  def fetch_order_data
    
    request_path      = Rails.application.routes.recognize_path(request.referer)
    @current_unit     = Unit.find(current_user.unit_id)
    if request_path[:controller] == 'delivery_boys' && request_path[:action]== 'show'
      @delivery_boy   = DeliveryBoy.find(request_path[:id])
      @orders         = @delivery_boy.orders
      @orders         = @orders.orders_assigned_delivery_boy(@delivery_boy.id)
      delivery_boy_id = @delivery_boy.id
    elsif request_path[:controller] == 'delivery_boys' && request_path[:action]== 'assign_order'
      @delivery_boys  = @current_unit.delivery_boys
      @orders         = Order.orders_by_unit(current_user.unit_id)
      
      delivery_boy_id = nil
    end

    data_array                = Hash.new
    
   
    outlet_info = Hash.new
    outlet_info[:marker_info]     = [@current_unit.latitude, @current_unit.longitude]
    outlet_info[:restaurant_name] = @current_unit.unit_name
    
    data_array[:source] = outlet_info
    
    data_array[:destinations] = Array.new
    @orders.each do |order|
      if order.deliverable.latitude != 0 || order.deliverable.longitude != 0
        
        rel_order = Order.order_by_lat_lon(current_user.unit_id, order.deliverable.latitude ,order.deliverable.longitude,delivery_boy_id)
        if rel_order.any?
          order_info = Hash.new
          order_info[:marker_info]  = [order.deliverable.latitude ,order.deliverable.longitude]
          order_info[:order_info]   = {order_id: (order.id).to_s, orders: rel_order , location: order.deliverable.delivery_address}
        
          data_array[:destinations] << order_info
        end
        
      end
    end
      
    respond_to do |format|
      format.json { render json: data_array }
    end
  end

  def sign_in
    delivery_boy = DeliveryBoy.find_by_email(params[:email_id])
    if delivery_boy && delivery_boy.authenticate(params[:password])
      log_in delivery_boy
      respond_to do |format|
        format.json { render json: delivery_boy.to_json(:include => :units) }
      end
    else
      respond_to do |format|
        format.json { render json: {:error => "Credential mismathced."} }
      end
    end
  end

  private

  def set_module_details
    @module_id = "home_delivery"
    @module_title = "Home Delivery"
  end  
end
