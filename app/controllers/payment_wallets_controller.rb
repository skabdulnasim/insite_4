class PaymentWalletsController < ApplicationController
  # GET /payment_wallets
  # GET /payment_wallets.json
  def index
    @payment_wallets = PaymentWallet.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @payment_wallets }
    end
  end

  # GET /payment_wallets/1
  # GET /payment_wallets/1.json
  def show
    @payment_wallet = PaymentWallet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @payment_wallet }
    end
  end

  # GET /payment_wallets/new
  # GET /payment_wallets/new.json
  def new
    @payment_wallet = PaymentWallet.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @payment_wallet }
    end
  end

  # GET /payment_wallets/1/edit
  def edit
    @payment_wallet = PaymentWallet.find(params[:id])
  end

  # POST /payment_wallets
  # POST /payment_wallets.json
  def create
    @payment_wallet = PaymentWallet.new(payment_wallet_params)

    respond_to do |format|
      if @payment_wallet.save
        format.html { redirect_to @payment_wallet, notice: 'Payment wallet was successfully created.' }
        format.json { render json: @payment_wallet, status: :created, location: @payment_wallet }
      else
        format.html { render action: "new" }
        format.json { render json: @payment_wallet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payment_wallets/1
  # PATCH/PUT /payment_wallets/1.json
  def update
    @payment_wallet = PaymentWallet.find(params[:id])

    respond_to do |format|
      if @payment_wallet.update_attributes(payment_wallet_params)
        format.html { redirect_to @payment_wallet, notice: 'Payment wallet was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @payment_wallet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payment_wallets/1
  # DELETE /payment_wallets/1.json
  def destroy
    @payment_wallet = PaymentWallet.find(params[:id])
    @payment_wallet.destroy

    respond_to do |format|
      format.html { redirect_to payment_wallets_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def payment_wallet_params
      params.require(:payment_wallet).permit(:name)
    end
end
