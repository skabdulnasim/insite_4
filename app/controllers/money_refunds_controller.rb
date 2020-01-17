class MoneyRefundsController < ApplicationController
  # GET /money_refunds
  # GET /money_refunds.json
  def index
    @money_refunds = MoneyRefund.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @money_refunds }
    end
  end

  # GET /money_refunds/1
  # GET /money_refunds/1.json
  def show
    @money_refund = MoneyRefund.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @money_refund }
    end
  end

  # GET /money_refunds/new
  # GET /money_refunds/new.json
  def new
    @money_refund = MoneyRefund.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @money_refund }
    end
  end

  # GET /money_refunds/1/edit
  def edit
    @money_refund = MoneyRefund.find(params[:id])
  end

  # POST /money_refunds
  # POST /money_refunds.json
  def create
    @money_refund = MoneyRefund.new(money_refund_params)

    respond_to do |format|
      if @money_refund.save
        format.html { redirect_to @money_refund, notice: 'Money refund was successfully created.' }
        format.json { render json: @money_refund, status: :created, location: @money_refund }
      else
        format.html { render action: "new" }
        format.json { render json: @money_refund.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /money_refunds/1
  # PATCH/PUT /money_refunds/1.json
  def update
    @money_refund = MoneyRefund.find(params[:id])

    respond_to do |format|
      if @money_refund.update_attributes(money_refund_params)
        format.html { redirect_to @money_refund, notice: 'Money refund was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @money_refund.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /money_refunds/1
  # DELETE /money_refunds/1.json
  def destroy
    @money_refund = MoneyRefund.find(params[:id])
    @money_refund.destroy

    respond_to do |format|
      format.html { redirect_to money_refunds_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def money_refund_params
      params.require(:money_refund).permit(:account_no, :customer_id, :ifsc_code, :order_id, :paymentmode, :refund_amount)
    end
end
