include ThirdPartyPaymentOptionsHelper
class ThirdPartyPaymentOptionsController < ApplicationController
  layout "material"
  third_party_payments_index_apipie_doc
  # GET /third_party_payment_options
  # GET /third_party_payment_options.json
  def index
    @third_party_payment_options = ThirdPartyPaymentOption.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @third_party_payment_options }
    end
  end

  # GET /third_party_payment_options/1
  # GET /third_party_payment_options/1.json
  def show
    @third_party_payment_option = ThirdPartyPaymentOption.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @third_party_payment_option }
    end
  end

  # GET /third_party_payment_options/new
  # GET /third_party_payment_options/new.json
  def new
    @third_party_payment_option = ThirdPartyPaymentOption.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @third_party_payment_option }
    end
  end

  # GET /third_party_payment_options/1/edit
  def edit
    @third_party_payment_option = ThirdPartyPaymentOption.find(params[:id])
  end

  # POST /third_party_payment_options
  # POST /third_party_payment_options.json
  def create
    @third_party_payment_option = ThirdPartyPaymentOption.new(third_party_payment_option_params)
    @third_party_payment_option[:is_trashed]=false
    respond_to do |format|
      if @third_party_payment_option.save
        format.html { redirect_to @third_party_payment_option, notice: 'Third party payment option was successfully created.' }
        format.json { render json: @third_party_payment_option, status: :created, location: @third_party_payment_option }
      else
        format.html { render action: "new" }
        format.json { render json: @third_party_payment_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /third_party_payment_options/1
  # PATCH/PUT /third_party_payment_options/1.json
  def update
    @third_party_payment_option = ThirdPartyPaymentOption.find(params[:id])

    respond_to do |format|
      if @third_party_payment_option.update_attributes(third_party_payment_option_params)
        format.html { redirect_to @third_party_payment_option, notice: 'Third party payment option was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @third_party_payment_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /third_party_payment_options/1
  # DELETE /third_party_payment_options/1.json
  def destroy
    @third_party_payment_option = ThirdPartyPaymentOption.find(params[:id])
    @third_party_payment_option.destroy

    respond_to do |format|
      format.html { redirect_to third_party_payment_options_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def third_party_payment_option_params
      params.require(:third_party_payment_option).permit(:is_trashed, :name, :status)
    end
end
