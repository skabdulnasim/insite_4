class OwnCustomerAddressesController < ApplicationController
  # GET /own_customer_addresses
  # GET /own_customer_addresses.json
  def index
    @own_customer_addresses = OwnCustomerAddress.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @own_customer_addresses }
    end
  end

  # GET /own_customer_addresses/1
  # GET /own_customer_addresses/1.json
  def show
    @own_customer_address = OwnCustomerAddress.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @own_customer_address }
    end
  end

  # GET /own_customer_addresses/new
  # GET /own_customer_addresses/new.json
  def new
    @own_customer_address = OwnCustomerAddress.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @own_customer_address }
    end
  end

  # GET /own_customer_addresses/1/edit
  def edit
    @own_customer_address = OwnCustomerAddress.find(params[:id])
  end

  # POST /own_customer_addresses
  # POST /own_customer_addresses.json
  def create
    @own_customer_address = OwnCustomerAddress.new(own_customer_address_params)

    respond_to do |format|
      if @own_customer_address.save
        format.html { redirect_to @own_customer_address, notice: 'Own customer address was successfully created.' }
        format.json { render json: @own_customer_address, status: :created, location: @own_customer_address }
      else
        format.html { render action: "new" }
        format.json { render json: @own_customer_address.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /own_customer_addresses/1
  # PATCH/PUT /own_customer_addresses/1.json
  def update
    @own_customer_address = OwnCustomerAddress.find(params[:id])

    respond_to do |format|
      if @own_customer_address.update_attributes(own_customer_address_params)
        format.html { redirect_to @own_customer_address, notice: 'Own customer address was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @own_customer_address.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /own_customer_addresses/1
  # DELETE /own_customer_addresses/1.json
  def destroy
    @own_customer_address = OwnCustomerAddress.find(params[:id])
    @own_customer_address.destroy

    respond_to do |format|
      format.html { redirect_to own_customer_addresses_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def own_customer_address_params
      params.require(:own_customer_address).permit(:city, :contact_no, :landmark, :latitude, :longitude, :pincode, :state)
    end
end
