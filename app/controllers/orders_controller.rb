include OrdersHelper
class OrdersController < ApplicationController
  load_and_authorize_resource :except => [ :update, :create, :cancel_order, :cancel_order_product, :update_order_status, :get_order_by_customer, :order_by_delivery_boy, :update_order_detail_status]
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  require 'rest-client'
  require 'json'

  layout "material"

  before_filter :set_module_details
  before_filter :set_timerange, only: [:index,:future_orders]

  # GET /orders
  # GET /orders.json
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  order_index_api
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def index
    _current_unit = params[:unit_id].present? ? params[:unit_id] : @current_user.unit_id
    @sections = Section.where("unit_id=?",_current_unit)
    # @sections.each do |sections|
    #   puts sections.inspect
    # end
    order_scope = Order.check_order_unit(_current_unit).order("orders.created_at desc")
    order_scope = order_scope.not_future
    order_scope = order_scope.check_order_status(params[:order_status_id]) if params[:order_status_id].present?
    order_scope = order_scope.order_canceled if params[:order_canceled].present?
    order_scope = order_scope.check_order_source(params[:order_source]) if params[:order_source].present?
    order_scope = order_scope.by_deliverable_type(params[:deliverable_type]) if params[:deliverable_type].present?
    order_scope = order_scope.check_order_deliverable_id(params[:deliverable_id]) if params[:deliverable_id].present?
    order_scope = order_scope.check_order_consumer_type(params[:consumer_type]) if params[:consumer_type].present?
    order_scope = order_scope.check_order_consumer_id(params[:consumer_id]) if params[:consumer_id].present?
    order_scope = order_scope.check_order_billed(params[:billed]) if params[:billed].present?
    order_scope = order_scope.orders_after_id(params[:orders_after_id]) if params[:orders_after_id].present?
    order_scope = order_scope.by_trash(params[:cancled]) if params[:cancled].present?
    order_scope = order_scope.set_id(params[:id_filter]) if params[:id_filter].present?
    order_scope = order_scope.not_asign_orders if params[:delivery_boy].present?

    ##################### for portal , each parameter may have array ##############################
    if current_user.present?
      if current_user.stores.present?
        @stores = current_user.stores
        _store_arr = Array.new
        @stores.each do |store|
          _store_arr.push(store.id)
        end
        order_scope = order_scope.set_store_id_in(_store_arr)
      end 
    end   
    order_scope = order_scope.check_order_status(params['order_status_ids']) if params['order_status_ids'].present?
    order_scope = order_scope.check_store_id_in(params['store_ids']) if params['store_ids'].present?
    order_scope = order_scope.check_order_source(params[:order_sources]) if params[:order_sources].present?
    order_scope = order_scope.check_order_deliverable_types(params[:order_deliverable_types]) if params[:order_deliverable_types].present?
    order_scope = order_scope.by_recorded_at(@from_datetime,@to_datetime) if params[:from_date].present?
    order_scope = order_scope.by_billed_status(params[:billed]) if params[:billed].present?
    order_scope = order_scope.by_stock_issue(params[:stock_issue_status]) if params[:stock_issue_status].present?
    order_scope = order_scope.joins(:order_slots).merge(OrderSlot.set_slot_in(params[:slot_ids])) if params[:slot_ids].present?
    order_scope = order_scope.by_delivery_date(params[:delivery_date]) if params[:delivery_date].present?

    smart_listing_create :orders, order_scope, partial: "orders/orders_smartlist", default_sort: {created_at: "desc"}
    @order_statuses = OrderStatus.all
    respond_to do |format|
      format.js # index.js.erb
      format.html # index.html.erb
      format.json { render json: order_scope.to_json(:include => [:consumer, :bills, :deliverable,:order_details=>
                                  {:include => [{:menu_product => {:include => {:product=> { :only => [:id, :name] }}}}, {:order_detail_combinations =>
                                    {:include => {:menu_product_combination =>
                                      {:include => [:combination_type, :combinations_rule, :product=> { :only => [:id, :name] }]}}}}]}
                                      ]) }
    end
  end
  # GET /orders/1
  # GET /orders/1.json
  def show
    @order = Order.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @order.to_json(:include => [:bills,{:deliverable => {:include => :additional_information}},{:consumer => {:include => :profile}},:order_details=>
                                  {:include => [{:menu_product=> {:include =>{:product=> { :only => [:id, :name] }}}}, {:order_detail_combinations =>
                                    {:include => {:menu_product_combination =>
                                      {:include => [:combination_type, :combinations_rule, :product=> { :only => [:id, :name] }]}}}}, :product, :sort]}]) }
    end
  end

  # GET /orders/new
  # GET /orders/new.json
  def new
    @order = Order.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @order }
    end
  end

  # GET /orders/1/edit
  def edit
    @order = Order.find(params[:id])
    @order_detail = OrderDetail.where(:order_id => params[:id], :trash => 0)
  end

  # POST /orders
  # POST /orders.json
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  order_create_api
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def create
    begin
      ActiveRecord::Base.transaction do
        @order = Order.new(order_params)
        if @order.save
          respond_to do |format|
            format.json { render json: @order.reload.id, status: :created }
          end
        else
          raise error_messages_for(@order)
        end
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      respond_to do |format|
        format.json { render json: [{:error => e.message.to_s}] }
      end
    end
  end

  # PUT /orders/1
  # PUT /orders/1.json
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  order_update_api
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def update
    @order = Order.find(params[:id])
    begin
      Order.swap_deliverable(@order, params[:deliverable_type], params[:deliverable_id]) if params[:deliverable_id].present? and params[:deliverable_type].present?
      respond_to do |format|
        format.json { render json: {:success => "Order successfully updated."} }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      respond_to do |format|
        format.json { render json: {:error => e.message.to_s} }
      end
    end
  end

  # # DELETE /orders/1
  # # DELETE /orders/1.json
  def destroy
    @order = Order.find(params[:id])
    @order_details = OrderDetail.where(:order_id => params[:id])
    @order_details.each do |order_detail|
      order_detail.destroy
    end
    @order.destroy

    respond_to do |format|
      format.html { redirect_to orders_url , notice: 'Order was successfully Deleted.' }
      format.json { head :no_content }
    end
  end

  def urbanpiper_status
    @ext_order = ExternalOrder.find_by_order_id(params[:order_id])
    if @ext_order.present?
      if @ext_order.order_source == "urban_piper"
        @status_hash={}
        @status_hash["new_status"] = params[:new_status]
        @status_hash["message"] = nil
        @res=ThirdpartyUrbanpiper.thirdparty_urbanpiper_order_status(@ext_order.external_order_id,@status_hash.to_json)
        if @res==true
          redirect_to :back, notice: 'Urbanpiper order status successfully changed.'
        else
          redirect_to :back, alert: 'Urbanpiper order status not changed.'
        end
      else
        redirect_to :back, alert: 'It is not an urbanpiper order.'
      end 
    else
      redirect_to :back, alert: 'It is not an thirdparty order.'
    end
  end

  def trash
    @order = Order.find(params[:id])
    @order_details = OrderDetail.where(:order_id => params[:id])
    @order_details.each do |order_detail|
      #order_detail.destroy
      order_detail[:trash] = 1
      order_detail.save
    end
    #@order.destroy
    @order[:trash] = 1
    @order.save

    respond_to do |format|
      format.html { redirect_to orders_url , notice: 'Order was successfully Deleted.' }
      format.json { head :no_content }
    end
  end

  def issue_stock
    begin
      @order = Order.find(params[:id])
      ActiveRecord::Base.transaction do
        @order.order_details.each do |item|
          if item.stock_not_issued_yet?
            stock_of_items = item.issue_stock
            raise "Some item(s) (#{stock_of_items[:insufficient_items].uniq.join(', ')}) or it's ingredient(s) (#{stock_of_items[:insufficient_ingredients].uniq.join(', ')}) or customization(s) (#{stock_of_items[:insufficient_customizations].uniq.join(', ')}) in this order, have insufficient stock" if stock_of_items[:insufficient_items].present? or stock_of_items[:insufficient_ingredients].present? or stock_of_items[:insufficient_customizations].present?
          end
        end
      end
      respond_to do |format|
        format.json { render json: {:success => "Stock issued.",:status => 'ok'} }
        format.html { redirect_to orders_url , notice: 'Stock issued for order items.' }
      end  
    rescue Exception => e
      Rscratch::Exception.log e,request
      respond_to do |format|
        format.json { render json: {:error => e.message.to_s, :status => 'error'} }
        format.html { redirect_to orders_url, :alert => e.message }
      end
    end
  end

  # GET /orders/get_order_by_customer.json
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  get_order_by_customer_api
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#

  def get_order_by_customer
    _order_details = OrderManagement::get_hl_orders()
    respond_to do |format|
      format.json { render json: _order_details.to_json(:include => [:bills,{:deliverable => {:include => [:customer => {:include => :customer_profile}]}},:order_details=>
                          {:include => [{:menu_product => {:include => :product}},{:order_detail_combinations =>
                          {:include => {:menu_product_combination =>
                          {:include => [:combination_type, :combinations_rule, :product=> { :only => [:id, :name] }]}}}}]}]) }
    end
  end


  # GET /orders/cancel_order/?order_id=2
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  cancel_order_api
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def cancel_order
    order_id = params[:id]
    cancel_cause = params[:cancel_cause]
    #puts order_id
    OrderManagement::cancel_order(order_id, cancel_cause)

    #<<<<<<<<<<<<<<<<<<<< START THIRD PARTI ORDER CANCLE >>>>>>>>>>>>>>>>#
    @ext_order = ExternalOrder.find_by_order_id(order_id)
    if @ext_order.present?
      if @ext_order.order_source.present? && @ext_order.order_source == "urban_piper"
        @status_hash={}
        @status_hash["new_status"] = "Cancelled"
        @status_hash["message"] = cancel_cause
        ThirdpartyUrbanpiper.thirdparty_urbanpiper_order_status(@ext_order.external_order_id,@status_hash.to_json)
      elsif @ext_order.order_source.present? && @ext_order.order_source == "zomato"
        @status_parm={}
        @status_parm["order_id"] = @ext_order.external_order_id
        @status_parm["rejection_message_id"] = 1
        @status_parm["vendor_rejection_message"] = cancel_cause
        @status_response=ThirdpartyZomato.thirdparty_zomato_status_reject(@status_parm.to_json)


        puts "OOOOOOOOOOOOOO"
        puts @status_response.inspect
      end
    end
    #<<<<<<<<<<<<<<<<<<<< END THIRD PARTI ORDER CANCLE >>>>>>>>>>>>>>>>#

    respond_to do |format|
      format.html { redirect_to orders_url }
      format.json { render json: {:success => "You have succesfully canceled the full order"} }
    end
  end

  # GET /orders/cancel_order_product/?order_details_id=2
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  cancel_order_product_api
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def cancel_order_product
    order_details_id = params[:order_details_id]
    cancel_cause = params[:cancel_cause]
    OrderManagement::cancel_order_product(order_details_id, cancel_cause)
    respond_to do |format|
      if params[:abs_url]
        abs_url = params[:abs_url]
        format.html { redirect_to abs_url }
      end
      format.json { render json: {:success => "You have succesfully canceled this item"} }
    end
  end

  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  update_order_status_api
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def update_order_status
    ActiveRecord::Base.transaction do
      message = Array.new
      JSON.parse(params[:order_ids]).each do |order_id|
        message.push OrderManagement::update_order_status(order_id['id'], params[:order_status_id], params[:user_id])
      end
      respond_to do |format|
        format.html { redirect_to orders_url }
        format.json { render json: message }
      end
    end
    rescue Exception => e
      Rscratch::Exception.log e,request
      respond_to do |format|
        format.html { redirect_to orders_url, :notice => e.message }
        format.json { render json: {:error => e.message} }
      end
  end

  def update_order_state
    ActiveRecord::Base.transaction do
      message = Array.new
      message.push OrderManagement::update_order_state(params[:order_id], params[:order_status_id], params[:user_id])
      respond_to do |format|
        format.html { redirect_to orders_url }
        format.json { render json: message }
      end
    end
    rescue Exception => e
      Rscratch::Exception.log e,request
      respond_to do |format|
        format.html { redirect_to orders_url, :notice => e.message }
        format.json { render json: {:error => e.message} }
      end
  end

  def manage_settings
    @order_statuses = OrderStatus.all
    @order_status = OrderStatus.new
  end

  # GET /orders/order_by_delivery_boy.json
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  order_by_delivery_boy_api
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def order_by_delivery_boy
    delivery_boy_id = params[:delivery_boy_id]
    order_scope = Order.where(:id != nil)
    order_scope = order_scope.order_by_delivery_boy_id(params[:delivery_boy_id]) if params[:delivery_boy_id].present?
    order_scope = order_scope.check_order_unit(params[:unit_id]) if params[:unit_id].present?
    order_scope = order_scope.check_order_status(params[:order_status_id]) if params[:order_status_id].present?
    order_scope = order_scope.order_canceled if params[:order_canceled].present?
    order_scope = order_scope.check_order_source(params[:order_source]) if params[:order_source].present?

    respond_to do |format|
      # format.json { render json: order_scope }
      format.json { render json: order_scope.to_json(:include => [:bills,{:deliverable => {:include => [:customer => {:include => :customer_profile}]}},:order_details=>
                          {:include => {:menu_product => {:include => :product}}}]) }
    end
  end

  def future_orders
    _current_unit = params[:unit_id].present? ? params[:unit_id] : @current_user.unit_id
    order_scope = Order.check_order_unit(_current_unit).order("orders.created_at desc")
    order_scope = order_scope.check_order_status(8) #use future order state id
    order_scope = order_scope.by_recorded_at(@from_datetime,@to_datetime) if params[:from_date].present?
    order_scope = order_scope.check_order_source(params[:order_sources]) if params[:order_sources].present? 
    order_scope = order_scope.set_id(params[:id_filter]) if params[:id_filter].present?
    # order_scope = order_scope.by_delivery_date(@from_datetime) if params[:delivery_date].present?
    order_scope = order_scope.upto_delivery_date(@from_datetime) if params[:delivery_date].present?
    smart_listing_create :future_orders, order_scope, partial: "orders/future_order_smartlisting", default_sort: {created_at: "desc"}
    respond_to do |format|
      format.js # index.js.erb
      format.html # index.html.erb
    end
  end

  def order_accumulation
    begin
      ActiveRecord::Base.transaction do
        raise "No order selected" if !params[:future_orders_array].present?
        @store_requisition = StoreRequisition.new
        @store_id = params[:store_id]
        @destination_stores = (AppConfiguration.get_config_value('stock_transfer_to_secondary_store') == 'enabled') ? Store.store_id_not(@store_id).not_return.primary_secondery : Store.store_id_not(@store_id).physical.primary
        @total_products = {}
        future_orders_ids = params[:future_orders_array].split(',')
        future_orders_ids.each do |future_order_id|
          order = Order.find(future_order_id)
          order_details = order.order_details
          if order_details.present?
            order_details.each do |order_detail|
              if @total_products.has_key? order_detail.product_id
                @total_products[order_detail.product_id] += order_detail.quantity
              else
                @total_products[order_detail.product_id] = order_detail.quantity
              end
            end
          end
        end
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to future_orders_orders_path, alert: e.message.to_s
    end
  end

  def import
    begin
      ActiveRecord::Base.transaction do
        _error_message=[]
        if params[:file].present?
          file_type=params[:file].original_filename.split('.')
          raise "File format must be csv." unless file_type.last == "csv"
          total_rows = CSV.foreach(params[:file].path,headers:true).count
          if total_rows > 500
            _error_message.push "Number of Row must not exceed 500"
          end
          if !_error_message.blank?
            _error_message.push("please check the sheet again.")
            redirect_to :back, alert: _error_message.join(",")
          else
            # insert_bulk_oders(params[:file],params[:menu_card_id])
            result = validate_csv(params[:file],params[:menu_card_id])
            if result.blank?
              insert_bulk_oders(params[:file],params[:menu_card_id])
              redirect_to :back, notice: "#{total_rows} Order succesfully uploaded"
              puts "No errors file is eligible for bulk upload"
            else
              _error_message.push(result)
              redirect_to :back, alert:_error_message.join(",")
            end
          end
        else
          puts "file require"
        end
      end
    rescue Exception => e
      puts e.message
      flash[:error]= e.message
      redirect_to :back
    end
  end

  def validate_csv(file,menu_card_id)
    error=[]
    i=0
    CSV.foreach(file.path,headers:true) do |row|
      i+=1
      if !row["Product"].present? or !row["Ordered On"].present? or !row["SKU"].present?  or !row["Quantity"].present? or !row["Dispatch After date"].present?
        error.push("some mandatory fields are missing in the sheet at Row Number: #{i}")
      elsif !Product.find_by_name(row["Product"]).present?
        error.push("product- #{row["Product"]} does not exist")
      else
        # product_id = Product.find_by_name(row["Product"])
        # product_id=product_id.id
        # stock = Stock.where("product_id=? and sku=?",product_id,row["SKU"]).first
        # if !stock
        #   error.push("product #{row["Product"]} with SKU #{row["SKU"]} is  not present")
        # else
        #   error.push("insufficient stock for  #{row["Product"]}") unless stock.sku==0
        # end
      end
    end
    return error
  end

  def insert_bulk_oders(csv_file,menu_card_id)
    menu_card = MenuCard.find(menu_card_id)
    CSV.foreach(csv_file.path,headers:true) do |row|
      product = Product.find_by_name(row["Product"])
      menu_product=  MenuProduct.find_by_menu_card_id_and_product_id(menu_card_id,product.id)
      order_hash = {
                    :order_status_id=> 1,
                    :unit_id=> @current_user.unit_id,
                    :recorded_at=> Date.parse(row["Ordered On"]).to_s,
                    :consumer_type=> "User",
                    :source=> "fos",
                    :consumer_id=> @current_user.id,
                    :deliverable_type=> "Address",
                    :delivary_date=> Date.parse(row["Dispatch After date"]).to_s,
                    :device_id=> "YOTTO05",
                    :deliverable_id =>2,
                    :third_party_order_id=>row["Order Id"],
                    :order_details_attributes=> [
                      {
                        :menu_product_id=> menu_product.id,
                        :quantity=> row["Quantity"],
                        :product_unique_identity=>row["SKU"]
                      }
                    ] 
                  }
      @order = Order.new(order_hash)
      @order.save
    end
  end

  private
  def set_module_details
    @module_id = "orders"
    @module_title = "Orders"
  end

  def order_params
    {
      "unit_id"           => params[:unit_id],
      "source"            => params[:source],
      "order_status_id"   => params[:order_status_id],
      "order_sr_no"       => params[:order_sr_no],
      "serial_no"         => params[:serial_no],
      "deliverable_id"    => params[:deliverable_id],
      "deliverable_type"  => params[:deliverable_type],
      "consumer_id"       => params[:consumer_id],
      "consumer_type"     => params[:consumer_type],
      "device_id"         => params[:device_id],
      "delivary_date"     => params[:delivary_date],
      "delivery_boy_id"   => params[:delivery_boy_id],
      "customer_id"       => params[:customer_id],
      "recorded_at"       => params[:recorded_at] || Time.now.utc,
      "order_details_attributes" => (JSON.parse(params[:order_details])).map { |e|
        {
          "menu_product_id"           => e['menu_product_id'],
          "quantity"                  => e['quantity'],
          "product_unique_identity"   => e['product_unique_identity'],
          "weight"                    => e['weight'],
          "preferences"               => e['preferences'],
          "parcel"                    => e['parcel'],
          "bill_status"               => e['bill_status'],
          "remarks"                   => e['remarks'],
          "order_detail_combinations_attributes" => e['order_detail_combinations'].present? ? e['order_detail_combinations'].map { |c| { "menu_product_combination_id" => c['menu_product_combination_id'], "combination_qty" => c['combination_qty'],"product_unique_identity" => c['product_unique_identity']  } } : []
        }
      }
    }
  end
end
