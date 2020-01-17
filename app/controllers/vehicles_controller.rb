class VehiclesController < ApplicationController
  load_and_authorize_resource
  
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper  

  layout "material"

  before_filter :set_module_details
  before_filter :get_current_user, only: [:index, :create]

  # GET /vehicles
  # GET /vehicles.json
  def index
    @vehicles = Vehicle.unit_vehicles(@current_user.unit_id)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @vehicles }
    end
  end

  # GET /vehicles/1
  # GET /vehicles/1.json
  def show
    begin
      @vehicle = Vehicle.find(params[:id])
      smart_listing_create :pending_shipments, @vehicle.stock_transfers.pickup_pending.desc_order, partial: "vehicles/pickup_smartlist",default_sort: {created_at: "asc"}
      smart_listing_create :processing_shipments, @vehicle.stock_transfers.shipped.desc_order, partial: "vehicles/shipped_smartlist",default_sort: {created_at: "asc"}
      smart_listing_create :delivered_shipments, @vehicle.stock_transfers.delivered.desc_order, partial: "vehicles/delivered_smartlist",default_sort: {created_at: "asc"}
      respond_to do |format|
        format.html # show.html.erb
        format.js
        format.json { render json: @vehicle }
      end      
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to vehicles_path, alert: e.message
    end
  end

  # GET /vehicles/new
  # GET /vehicles/new.json
  def new
    @vehicle = Vehicle.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @vehicle }
    end
  end

  # GET /vehicles/1/edit
  def edit
    @vehicle = Vehicle.find(params[:id])
  end

  # POST /vehicles
  # POST /vehicles.json
  def create
    @vehicle = Vehicle.new(params[:vehicle])
    @vehicle[:unit_id] = @current_user.unit_id
    @vehicle[:pass_key] = rand(10000..99999)
    respond_to do |format|
      if @vehicle.save
        format.html { redirect_to @vehicle, notice: 'Vehicle was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /vehicles/1
  # PUT /vehicles/1.json
  def update
    @vehicle = Vehicle.find(params[:id])

    respond_to do |format|
      if @vehicle.update_attributes(params[:vehicle])
        format.html { redirect_to @vehicle, notice: 'Vehicle was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @vehicle.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vehicles/1
  # DELETE /vehicles/1.json
  def destroy
    @vehicle = Vehicle.find(params[:id])
    @vehicle.destroy

    respond_to do |format|
      format.html { redirect_to vehicles_url }
      format.json { head :no_content }
    end
  end
  private

  def set_module_details
    @module_id = "vehicles"
    @module_title = "Shipping"
  end  
end
