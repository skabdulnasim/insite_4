class FinancialAccountsController < ApplicationController
  # GET /financial_accounts
  # GET /financial_accounts.json
  def index
    @financial_accounts = FinancialAccount.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @financial_accounts }
    end
  end

  # GET /financial_accounts/1
  # GET /financial_accounts/1.json
  def show
    @financial_account = FinancialAccount.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @financial_account }
    end
  end

  # GET /financial_accounts/new
  # GET /financial_accounts/new.json
  def new
    @financial_account = FinancialAccount.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @financial_account }
    end
  end

  # GET /financial_accounts/1/edit
  def edit
    @financial_account = FinancialAccount.find(params[:id])
  end

  # POST /financial_accounts
  # POST /financial_accounts.json
  def create
    @financial_account = FinancialAccount.new(financial_account_params)

    respond_to do |format|
      if @financial_account.save
        format.html { redirect_to @financial_account, notice: 'Financial account was successfully created.' }
        format.json { render json: @financial_account, status: :created, location: @financial_account }
      else
        format.html { render action: "new" }
        format.json { render json: @financial_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /financial_accounts/1
  # PATCH/PUT /financial_accounts/1.json
  def update
    @financial_account = FinancialAccount.find(params[:id])

    respond_to do |format|
      if @financial_account.update_attributes(financial_account_params)
        format.html { redirect_to @financial_account, notice: 'Financial account was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @financial_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /financial_accounts/1
  # DELETE /financial_accounts/1.json
  def destroy
    @financial_account = FinancialAccount.find(params[:id])
    @financial_account.destroy

    respond_to do |format|
      format.html { redirect_to financial_accounts_url }
      format.json { head :no_content }
    end
  end

  def account_details
    @unit_financial_account = current_user.unit.financial_account
    if @unit_financial_account.present?
      @outlet_account_transactions = @unit_financial_account.financial_account_transactions.order("id desc").limit(10)
    end
    @customers = Customer.reverse

    respond_to do |format|
      format.html # index.html.erb
      format.csv { send_data FinancialAccount.account_transactions_history_to_csv(current_user.unit_id,params[:account_holder_type], params[:customer_id]), filename: "account-transaction-history.csv" }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def financial_account_params
      params.require(:financial_account).permit(:account_holder_id, :account_holder_type, :current_balance, :total_credit, :total_debit)
    end
end
