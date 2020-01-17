class ReasonCodesController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  # GET /reason_codes
  # GET /reason_codes.json
  def index
    @reason_codes = ReasonCode.order("master_model_id asc")
    smart_listing_create :reasoncodes, @reason_codes, partial: "reason_codes/reason_code_smartlist"
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @reason_codes }
    end
  end

  # GET /reason_codes/1
  # GET /reason_codes/1.json
  def show
    @reason_code = ReasonCode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @reason_code }
    end
  end

  # GET /reason_codes/new
  # GET /reason_codes/new.json
  def new
    @reason_code = ReasonCode.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @reason_code }
    end
  end

  # GET /reason_codes/1/edit
  def edit
    @reason_code = ReasonCode.find(params[:id])
  end

  # POST /reason_codes
  # POST /reason_codes.json
  def create
    @reason_code = ReasonCode.new(reason_code_params)

    respond_to do |format|
      if @reason_code.save
        format.html { redirect_to @reason_code, notice: 'Reason code was successfully created.' }
        format.json { render json: @reason_code, status: :created, location: @reason_code }
      else
        format.html { render action: "new" }
        format.json { render json: @reason_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reason_codes/1
  # PATCH/PUT /reason_codes/1.json
  def update
    @reason_code = ReasonCode.find(params[:id])

    respond_to do |format|
      if @reason_code.update_attributes(reason_code_params)
        format.html { redirect_to @reason_code, notice: 'Reason code was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @reason_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reason_codes/1
  # DELETE /reason_codes/1.json
  def destroy
    @reason_code = ReasonCode.find(params[:id])
    @reason_code.destroy

    respond_to do |format|
      format.html { redirect_to reason_codes_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def reason_code_params
      params.require(:reason_code).permit(:code, :master_model_id, :name, :status, :stock_adjustment)
    end
end
