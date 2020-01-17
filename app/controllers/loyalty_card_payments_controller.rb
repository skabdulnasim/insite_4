class LoyaltyCardPaymentsController < ApplicationController
  # GET /loyalty_card_payments
  # GET /loyalty_card_payments.json
  def index
    @loyalty_card_payments = LoyaltyCardPayment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @loyalty_card_payments }
    end
  end

  # GET /loyalty_card_payments/1
  # GET /loyalty_card_payments/1.json
  def show
    @loyalty_card_payment = LoyaltyCardPayment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @loyalty_card_payment }
    end
  end

  # GET /loyalty_card_payments/new
  # GET /loyalty_card_payments/new.json
  def new
    @loyalty_card_payment = LoyaltyCardPayment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @loyalty_card_payment }
    end
  end

  # GET /loyalty_card_payments/1/edit
  def edit
    @loyalty_card_payment = LoyaltyCardPayment.find(params[:id])
  end

  # POST /loyalty_card_payments
  # POST /loyalty_card_payments.json
  def create
    @loyalty_card_payment = LoyaltyCardPayment.new(loyalty_card_payment_params)

    respond_to do |format|
      if @loyalty_card_payment.save
        format.html { redirect_to @loyalty_card_payment, notice: 'Loyalty card payment was successfully created.' }
        format.json { render json: @loyalty_card_payment, status: :created, location: @loyalty_card_payment }
      else
        format.html { render action: "new" }
        format.json { render json: @loyalty_card_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /loyalty_card_payments/1
  # PATCH/PUT /loyalty_card_payments/1.json
  def update
    @loyalty_card_payment = LoyaltyCardPayment.find(params[:id])

    respond_to do |format|
      if @loyalty_card_payment.update_attributes(loyalty_card_payment_params)
        format.html { redirect_to @loyalty_card_payment, notice: 'Loyalty card payment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @loyalty_card_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /loyalty_card_payments/1
  # DELETE /loyalty_card_payments/1.json
  def destroy
    @loyalty_card_payment = LoyaltyCardPayment.find(params[:id])
    @loyalty_card_payment.destroy

    respond_to do |format|
      format.html { redirect_to loyalty_card_payments_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def loyalty_card_payment_params
      params.require(:loyalty_card_payment).permit(:amount, :card_identity, :loyalty_card, :name_on_card, :points_used)
    end
end
