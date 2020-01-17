class ResourceOrderHistoryDetailsController < ApplicationController
  # GET /resource_order_history_details
  # GET /resource_order_history_details.json
  def index
    @resource_order_history_details = ResourceOrderHistoryDetail.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @resource_order_history_details }
    end
  end

  # GET /resource_order_history_details/1
  # GET /resource_order_history_details/1.json
  def show
    @resource_order_history_detail = ResourceOrderHistoryDetail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @resource_order_history_detail }
    end
  end

  # GET /resource_order_history_details/new
  # GET /resource_order_history_details/new.json
  def new
    @resource_order_history_detail = ResourceOrderHistoryDetail.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @resource_order_history_detail }
    end
  end

  # GET /resource_order_history_details/1/edit
  def edit
    @resource_order_history_detail = ResourceOrderHistoryDetail.find(params[:id])
  end

  # POST /resource_order_history_details
  # POST /resource_order_history_details.json
  def create
    @resource_order_history_detail = ResourceOrderHistoryDetail.new(resource_order_history_detail_params)

    respond_to do |format|
      if @resource_order_history_detail.save
        format.html { redirect_to @resource_order_history_detail, notice: 'Resource order history detail was successfully created.' }
        format.json { render json: @resource_order_history_detail, status: :created, location: @resource_order_history_detail }
      else
        format.html { render action: "new" }
        format.json { render json: @resource_order_history_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /resource_order_history_details/1
  # PATCH/PUT /resource_order_history_details/1.json
  def update
    @resource_order_history_detail = ResourceOrderHistoryDetail.find(params[:id])

    respond_to do |format|
      if @resource_order_history_detail.update_attributes(resource_order_history_detail_params)
        format.html { redirect_to @resource_order_history_detail, notice: 'Resource order history detail was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @resource_order_history_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resource_order_history_details/1
  # DELETE /resource_order_history_details/1.json
  def destroy
    @resource_order_history_detail = ResourceOrderHistoryDetail.find(params[:id])
    @resource_order_history_detail.destroy

    respond_to do |format|
      format.html { redirect_to resource_order_history_details_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def resource_order_history_detail_params
      params.require(:resource_order_history_detail).permit(:menu_product_id, :product_id, :product_name, :recorded_at, :remrks, :unit_id, :user_id)
    end
end
