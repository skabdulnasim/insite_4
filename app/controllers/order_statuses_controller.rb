class OrderStatusesController < ApplicationController
  load_and_authorize_resource
  # GET /statuses
  # GET /statuses.json
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  api :GET, '/order_statuses.json', "Get all order statuses"
  error :code => 401, :desc => "Unauthorized"
  description "Get all order statuses of a client" 
  formats ['json', 'html']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def index
    @order_statuses = OrderStatus.order("id asc")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @order_statuses }
    end
  end

  # GET /statuses/1
  # GET /statuses/1.json
  def show
    @order_status = OrderStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @order_status }
    end
  end

  # GET /statuses/new
  # GET /statuses/new.json
  def new
    @order_status = OrderStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @order_status }
    end
  end

  # GET /statuses/1/edit
  def edit
    @order_status = OrderStatus.find(params[:id])
  end

  # POST /statuses
  # POST /statuses.json
  def create
    @order_status = OrderStatus.new(params[:order_status])

    respond_to do |format|
      if @order_status.save
        format.html { redirect_to orders_manage_settings_path, notice: 'OrderStatus was successfully created.' }
        format.json { render json: @order_status, status: :created, location: @order_status }
      else
        format.html { redirect_to orders_manage_settings_path, notice: 'OrderStatus was not created.' }
        format.json { render json: @order_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /statuses/1
  # PUT /statuses/1.json
  def update
    @order_status = OrderStatus.find(params[:id])
    
    respond_to do |format|
      if @order_status.update_attributes(params[:order_status])
        format.html { redirect_to orders_manage_settings_path, notice: 'OrderStatus was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @order_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /statuses/1
  # DELETE /statuses/1.json
  def destroy
    @order_status = OrderStatus.find(params[:id])
    @order_status.destroy

    respond_to do |format|
      format.html { redirect_to orders_manage_settings_path, notice: 'Order Status was successfully deleted.' }
      format.json { head :no_content }
    end
  end
end
