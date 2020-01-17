class DeliveryChargesController < ApplicationController
  # GET /delivery_charges
  # GET /delivery_charges.json
  def index
    @delivery_charges = DeliveryCharge.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @delivery_charges }
    end
  end

  # GET /delivery_charges/1
  # GET /delivery_charges/1.json
  def show
    @delivery_charge = DeliveryCharge.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @delivery_charge }
    end
  end

  # GET /delivery_charges/new
  # GET /delivery_charges/new.json
  def new
    @delivery_charge = DeliveryCharge.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @delivery_charge }
    end
  end

  # GET /delivery_charges/1/edit
  def edit
    @delivery_charge = DeliveryCharge.find(params[:id])
  end

  # POST /delivery_charges
  # POST /delivery_charges.json
  def create
    @delivery_charge = DeliveryCharge.new(delivery_charge_params)

    respond_to do |format|
      if @delivery_charge.save
        format.html { redirect_to @delivery_charge, notice: 'Delivery charge was successfully created.' }
        format.json { render json: @delivery_charge, status: :created, location: @delivery_charge }
      else
        format.html { render action: "new" }
        format.json { render json: @delivery_charge.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /delivery_charges/1
  # PATCH/PUT /delivery_charges/1.json
  def update
    @delivery_charge = DeliveryCharge.find(params[:id])

    respond_to do |format|
      if @delivery_charge.update_attributes(delivery_charge_params)
        format.html { redirect_to @delivery_charge, notice: 'Delivery charge was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @delivery_charge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /delivery_charges/1
  # DELETE /delivery_charges/1.json
  def destroy
    @delivery_charge = DeliveryCharge.find(params[:id])
    @delivery_charge.destroy

    respond_to do |format|
      format.html { redirect_to delivery_charges_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def delivery_charge_params
      params.require(:delivery_charge).permit(:delivery_charge, :lower_limit, :unit_id, :upper_limit)
    end
end
