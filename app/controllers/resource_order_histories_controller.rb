class ResourceOrderHistoriesController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  # GET /resource_order_histories
  # GET /resource_order_histories.json
  def index
    @resource_order_histories = ResourceOrderHistory.order("id ASC")
    smart_listing_create(:resource_orders,@resource_order_histories,  partial: "resource_order_histories/resource_orders")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @resource_order_histories }
    end
  end

  # GET /resource_order_histories/1
  # GET /resource_order_histories/1.json
  def show
    @resource_order_history = ResourceOrderHistory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @resource_order_history }
    end
  end

  # GET /resource_order_histories/new
  # GET /resource_order_histories/new.json
  def new
    @resource_order_history = ResourceOrderHistory.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @resource_order_history }
    end
  end

  # GET /resource_order_histories/1/edit
  def edit
    @resource_order_history = ResourceOrderHistory.find(params[:id])
  end

  # POST /resource_order_histories
  # POST /resource_order_histories.json
  def create
    @resource_order_history = ResourceOrderHistory.new(resource_order_history_params)

    respond_to do |format|
      if @resource_order_history.save
        format.html { redirect_to @resource_order_history, notice: 'Resource order history was successfully created.' }
        format.json { render json: @resource_order_history, status: :created, location: @resource_order_history }
      else
        format.html { render action: "new" }
        format.json { render json: @resource_order_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /resource_order_histories/1
  # PATCH/PUT /resource_order_histories/1.json
  def update
    @resource_order_history = ResourceOrderHistory.find(params[:id])

    respond_to do |format|
      if @resource_order_history.update_attributes(resource_order_history_params)
        format.html { redirect_to @resource_order_history, notice: 'Resource order history was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @resource_order_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resource_order_histories/1
  # DELETE /resource_order_histories/1.json
  def destroy
    @resource_order_history = ResourceOrderHistory.find(params[:id])
    @resource_order_history.destroy

    respond_to do |format|
      format.html { redirect_to resource_order_histories_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def resource_order_history_params
      params.require(:resource_order_history).permit(:latitude, :longitude, :recorded_at, :resource_id, :unit_id, :user_id)
    end
end
