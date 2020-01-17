class LoyaltyCardTransactionsController < ApplicationController
  # GET /loyalty_card_transactions
  # GET /loyalty_card_transactions.json
  def index
    @loyalty_card_transactions = LoyaltyCardTransaction.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @loyalty_card_transactions }
    end
  end

  # GET /loyalty_card_transactions/1
  # GET /loyalty_card_transactions/1.json
  def show
    @loyalty_card_transaction = LoyaltyCardTransaction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @loyalty_card_transaction }
    end
  end

  # GET /loyalty_card_transactions/new
  # GET /loyalty_card_transactions/new.json
  def new
    @loyalty_card_transaction = LoyaltyCardTransaction.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @loyalty_card_transaction }
    end
  end

  # GET /loyalty_card_transactions/1/edit
  def edit
    @loyalty_card_transaction = LoyaltyCardTransaction.find(params[:id])
  end

  # POST /loyalty_card_transactions
  # POST /loyalty_card_transactions.json
  def create
    @loyalty_card_transaction = LoyaltyCardTransaction.new(loyalty_card_transaction_params)

    respond_to do |format|
      if @loyalty_card_transaction.save
        format.html { redirect_to @loyalty_card_transaction, notice: 'Loyalty card transaction was successfully created.' }
        format.json { render json: @loyalty_card_transaction, status: :created, location: @loyalty_card_transaction }
      else
        format.html { render action: "new" }
        format.json { render json: @loyalty_card_transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /loyalty_card_transactions/1
  # PATCH/PUT /loyalty_card_transactions/1.json
  def update
    @loyalty_card_transaction = LoyaltyCardTransaction.find(params[:id])

    respond_to do |format|
      if @loyalty_card_transaction.update_attributes(loyalty_card_transaction_params)
        format.html { redirect_to @loyalty_card_transaction, notice: 'Loyalty card transaction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @loyalty_card_transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /loyalty_card_transactions/1
  # DELETE /loyalty_card_transactions/1.json
  def destroy
    @loyalty_card_transaction = LoyaltyCardTransaction.find(params[:id])
    @loyalty_card_transaction.destroy

    respond_to do |format|
      format.html { redirect_to loyalty_card_transactions_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def loyalty_card_transaction_params
      params.require(:loyalty_card_transaction).permit(:loyalty_card_id, :transaction_type, :transaction_amount, :remarks, :loyalty_transaction_id, :loyalty_transaction_type)
    end
end
