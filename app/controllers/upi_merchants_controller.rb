class UpiMerchantsController < ApplicationController
  # GET /upi_merchants
  # GET /upi_merchants.json
  def index
    if UpiMerchant.first
      @upi_merchant = UpiMerchant.first
    else
      @upi_merchant = UpiMerchant.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @upi_merchant }
      end    
    end
  end

  # GET /upi_merchants/1
  # GET /upi_merchants/1.json
  def show
    @upi_merchant = UpiMerchant.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @upi_merchant }
    end
  end

  # GET /upi_merchants/new
  # GET /upi_merchants/new.json
  # def new
  #   @upi_merchant = UpiMerchant.new

  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.json { render json: @upi_merchant }
  #   end
  # end

  # GET /upi_merchants/1/edit
  def edit
    @upi_merchant = UpiMerchant.find(params[:id])
  end

  # POST /upi_merchants
  # POST /upi_merchants.json
  def create
    @upi_merchant = UpiMerchant.new(upi_merchant_params)

    respond_to do |format|
      if @upi_merchant.save
        format.html { redirect_to upi_merchants_path, notice: 'Upi merchant was successfully created.' }
        format.json { render json: @upi_merchant, status: :created, location: @upi_merchant }
      else
        format.html { render action: "new" }
        format.json { render json: @upi_merchant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /upi_merchants/1
  # PATCH/PUT /upi_merchants/1.json
  def update
    @upi_merchant = UpiMerchant.find(params[:id])

    respond_to do |format|
      if @upi_merchant.update_attributes(upi_merchant_params)
        format.html { redirect_to upi_merchants_path, notice: 'Upi merchant was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @upi_merchant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /upi_merchants/1
  # DELETE /upi_merchants/1.json
  def destroy
    @upi_merchant = UpiMerchant.find(params[:id])
    @upi_merchant.destroy

    respond_to do |format|
      format.html { redirect_to upi_merchants_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def upi_merchant_params
      params.require(:upi_merchant).permit(:am, :cu, :mam, :mc, :pa, :pn, :ref_url, :tid, :tn, :tr)
    end
end
