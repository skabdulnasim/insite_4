class OwnCustomersController < ApplicationController
  # GET /own_customers
  # GET /own_customers.json  
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  def index
    @own_customers = OwnCustomer.get_all
    smart_listing_create :own_customer, @own_customers, partial: "own_customers/own_customers_smartlisting"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @own_customers }
    end
  end

  # GET /own_customers/1
  # GET /own_customers/1.json
  def show
    @own_customer = OwnCustomer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @own_customer }
    end
  end

  # GET /own_customers/new
  # GET /own_customers/new.json
  def new
    @own_customer = OwnCustomer.new
    @own_customer_address = @own_customer.own_customer_addresses.build
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @own_customer }
    end
  end

  # GET /own_customers/1/edit
  def edit
    @own_customer = OwnCustomer.find(params[:id])
  end

  # POST /own_customers
  # POST /own_customers.json
  def create
    @own_customer = OwnCustomer.new(params[:own_customer])

    respond_to do |format|
      if @own_customer.save
        format.html { redirect_to @own_customer, notice: 'Own customer was successfully created.' }
        format.json { render json: @own_customer, status: :created, location: @own_customer }
      else
        format.html { render action: "new" }
        format.json { render json: @own_customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /own_customers/1
  # PATCH/PUT /own_customers/1.json
  def update
    @own_customer = OwnCustomer.find(params[:id])

    respond_to do |format|
      if @own_customer.update_attributes(own_customer_params)
        format.html { redirect_to @own_customer, notice: 'Own customer was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @own_customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /own_customers/1
  # DELETE /own_customers/1.json
  def destroy
    @own_customer = OwnCustomer.find(params[:id])
    @own_customer.destroy

    respond_to do |format|
      format.html { redirect_to own_customers_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def own_customer_params
      params.require(:own_customer).permit(:customer_unique_id, :email, :mobile_no, :name)
    end
end
