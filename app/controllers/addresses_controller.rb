class AddressesController < ApplicationController
  
  before_filter :set_customer

  # GET /addresses
  # GET /addresses.json
  def index
    @addresses = Address.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @addresses }
    end
  end

  # GET /addresses/1
  # GET /addresses/1.json
  # def show
  #   @address = Address.find(params[:id])

  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.json { render json: @address }
  #   end
  # end

  def show
    @address = Address.find(params[:id])
  end

  # GET /addresses/new
  # GET /addresses/new.json
  # def new
  #   @address = Address.new

  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.json { render json: @address }
  #   end
  # end

  def new
    @address = Address.new(:contact_no => @customer.mobile_no)
  end

  # GET /addresses/1/edit
  def edit
    @address = Address.find(params[:id])
  end

  # POST /addresses
  # POST /addresses.json
  # def create
  #   @address = Address.new(address_params)

  #   respond_to do |format|
  #     if @address.save
  #       format.html { redirect_to @address, notice: 'Address was successfully created.' }
  #       format.json { render json: @address, status: :created, location: @address }
  #     else
  #       format.html { render action: "new" }
  #       format.json { render json: @address.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  def create
    @address = @customer.addresses.new(params[:address])
    @address.save
  end

  # PATCH/PUT /addresses/1
  # PATCH/PUT /addresses/1.json
  # def update
  #   @address = Address.find(params[:id])

  #   respond_to do |format|
  #     if @address.update_attributes(address_params)
  #       format.html { redirect_to @address, notice: 'Address was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: "edit" }
  #       format.json { render json: @address.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  def update
    @address = Address.find(params[:id])
    @address.update_attributes(params[:address])
  end

  # DELETE /addresses/1
  # DELETE /addresses/1.json
  def destroy
    @address = Address.find(params[:id])
    @address.destroy

    respond_to do |format|
      format.html { redirect_to addresses_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def address_params
      params.require(:address).permit(:city, :contact_no, :customer_id, :delivery_address, :landmark, :latitude, :locality, :longitude, :pincode, :place, :receiver_first_name, :receiver_last_name, :receiver_name, :state)
    end

    def set_customer
      @customer = Customer.find(params[:customer_id])
    end
end
