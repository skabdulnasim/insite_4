include OrderDetailsHelper
class OrderDetailsController < ApplicationController
  # GET /order_details
  # GET /order_details.json
  load_and_authorize_resource:except => [ :update, :update_order_detail_status]
  before_filter :set_timerange, only: [:index]
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  get_order_details_index_api
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def index
    @order_details = OrderDetail.all
    order_details_scope = OrderDetail.where(:id != nil)
    order_details_scope = order_details_scope.check_order_details_sort(params[:sort_id]).order('id DESC') if params[:sort_id].present?
    order_details_scope = order_details_scope.check_order_details_status(params[:status]).order('id DESC') if params[:status].present?
    order_details_scope = order_details_scope.by_date_range(@from_datetime,@to_datetime) if params[:from_date].present?

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: orders_index_json(order_details_scope) }
    end
  end

  # GET /order_details/1
  # GET /order_details/1.json
  def show
    @order_detail = OrderDetail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @order_detail }
    end
  end

  # GET /order_details/new
  # GET /order_details/new.json
  def new
    @order_detail = OrderDetail.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @order_detail }
    end
  end

  # GET /order_details/1/edit
  def edit
    @order_detail = OrderDetail.find(params[:id])
  end

  # POST /order_details
  # POST /order_details.json
  def create
    @order_detail = OrderDetail.new(params[:order_detail])

    respond_to do |format|
      if @order_detail.save
        format.html { redirect_to @order_detail, notice: 'Order detail was successfully created.' }
        format.json { render json: @order_detail, status: :created, location: @order_detail }
      else
        format.html { render action: "new" }
        format.json { render json: @order_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /order_details/1
  # PUT /order_details/1.json
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  update_order_detail_api
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def update
    begin
      ActiveRecord::Base.transaction do
        @order_detail = OrderDetail.find(params[:id])
        if params[:device_id].present?
          if params[:order_details].present?
            checked_stock = OrderDetail.check_order_detail_quantity(@order_detail,JSON.parse(params[:order_details]))
            # OrderDetail.check_order_detail_quantity(@order_detail,params[:order_details])
            if !checked_stock.empty?
              respond_to do |format|
                format.json { render json: checked_stock }
              end
            else
              respond_to do |format|
                format.json { render json: @order_detail.id }
              end
            end
          elsif params[:bill_status].present?
            @order_detail.update_attributes(:bill_status=>params[:bill_status], :remarks=>params[:remarks])
            update_bills(@order_detail.order) 
            respond_to do |format|
              format.json { render json: @order_detail.reload }
            end
          end
        else
          # PORTAL Request
          @order_detail.update_attributes(:bill_status=>params[:bill_status], :remarks=>params[:remarks]) if params[:bill_status].present?
          update_bills(@order_detail.order) 
          respond_to do |format|
            format.json { render json: @order_detail }
          end
        end
      end  
    rescue Exception => e
      Rscratch::Exception.log e,request
      respond_to do |format|
        format.json { render json: {:error => e.message.to_s} }
      end  
    end
  end

  # DELETE /order_details/1
  # DELETE /order_details/1.json
  def destroy
    @order_detail = OrderDetail.find(params[:id])
    @order_detail.destroy

    respond_to do |format|
      format.html { redirect_to order_details_url }
      format.json { head :no_content }
    end
  end

  # POST /order_details/update_order_detail_status
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  update_order_detail_status_api
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def update_order_detail_status
    begin
      ActiveRecord::Base.transaction do
        JSON.parse(params[:order_detail_ids]).each do |order_detail_id|
          order_detail = OrderDetail.find(order_detail_id['id'])
          order_detail.update_column(:status, params[:status])
          _subdomain = AppConfiguration.find_by_config_key('site_id')
          # Push notification for new order details *ANDROID*
          _channels = Array.new
          #_channels.push '/notifications/portal/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/order_item_update'
          _channels.push '/notifications/android/subdomain/'+_subdomain.config_value.to_s+'/unit/'+order_detail.order.unit_id.to_s+'/order_item_update'
          Notification.publish_in_faye(_channels,{:order_item => order_detail})
          # OrderDetail::update_order_detail_status(order_detail_id['id'], params[:status], params[:user_id])
        end
      end
      respond_to do |format|
        format.json { render json: {:success => "You have succesfully changed the status"} }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      respond_to do |format|
        format.json { render json: {:error => e.message} }
      end
    end
  end

  private

  def update_bills(order)
    if order.bills.present?
      _bill = order.bills.first 
      Bill.update_bill_amounts(_bill)
      Bill.calculate_bill_taxes(_bill)
    end
  end
end
