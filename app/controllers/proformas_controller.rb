class ProformasController < ApplicationController

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  def index
    @proformas = Proforma.order("id desc")
    @proformas = @proformas.set_id(params[:id_filter]) if params[:id_filter].present?
    smart_listing_create :proformas, @proformas, partial: "proformas/proformas_smartlist"
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @proformas }
      format.js
    end
  end

  # GET /proformas/1
  # GET /proformas/1.json
  def show
    @proforma = Proforma.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @proforma }
    end
  end

  # GET /proformas/new
  # GET /proformas/new.json
  def new
    @proforma = Proforma.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @proforma }
    end
  end

  # GET /proformas/1/edit
  def edit
    @proforma = Proforma.find(params[:id])
  end

  # POST /proformas
  # POST /proformas.json
  def create
    @proforma = Proforma.new(proforma_params)

    respond_to do |format|
      if @proforma.save
        format.html { redirect_to @proforma, notice: 'Proforma was successfully created.' }
        format.json { render json: @proforma, status: :created, location: @proforma }
      else
        format.html { render action: "new" }
        format.json { render json: @proforma.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /proformas/1
  # PATCH/PUT /proformas/1.json
  def update
    @proforma = Proforma.find(params[:id])

    respond_to do |format|
      if @proforma.update_attributes(proforma_params)
        format.html { redirect_to @proforma, notice: 'Proforma was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @proforma.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /proformas/1
  # DELETE /proformas/1.json
  def destroy
    @proforma = Proforma.find(params[:id])
    @proforma.destroy

    respond_to do |format|
      format.html { redirect_to proformas_url }
      format.json { head :no_content }
    end
  end

  # def fetch_orders
  #   @orders = OrderProforma.where("proforma_id=?",params[:proforma_id]).pluck(:order_id)
  #   @orders = Order.by_id_in(@orders)
  #   puts @orders.inspect
  #   respond_to do |format|
  #     format.json { render :json => @orders }
  #   end
  # end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def proforma_params
      params.require(:proforma).permit(:customer_id, :device_id, :discount, :grand_total, :proforma_amount, :recorded_at, :remarks, :roundoff, :serial_no, :status, :tax_amount, :unit_id, :user_id)
    end
end
