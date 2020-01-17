class LoyaltyPurchasesController < ApplicationController
  layout "material"
  # GET /loyalty_purchases
  # GET /loyalty_purchases.json
  before_filter :day_to_date, only: [:create]
  def index
    @loyalty_purchases = LoyaltyPurchase.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @loyalty_purchases }
    end
  end

  # GET /loyalty_purchases/1
  # GET /loyalty_purchases/1.json
  def show
    @loyalty_purchase = LoyaltyPurchase.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @loyalty_purchase }
    end
  end

  # GET /loyalty_purchases/new
  # GET /loyalty_purchases/new.json
  def new
    @loyalty_purchase = LoyaltyPurchase.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @loyalty_purchase }
    end
  end

  # GET /loyalty_purchases/1/edit
  def edit
    @loyalty_purchase = LoyaltyPurchase.find(params[:id])
  end

  # POST /loyalty_purchases
  # POST /loyalty_purchases.json
  def create

    @loyalty_purchase = LoyaltyPurchase.new(loyalty_purchase_params)
    #@loyalty_purchase.purchase_cost = params[:loyalty_purchase][:purchase_cost]
    #@loyalty_purchase.purchase_type = params[:loyalty_purchase][:purchase_type]

    #@loyalty_purchase.loyalty_card_id = @loyalty_card.id
    
    respond_to do |format|
      if @loyalty_purchase.save
        #LoyaltyCardTransaction.create({:loyalty_card_id => @loyalty_purchase.loyalty_card_id,:transaction_type=>'credit',
         #                                          :transaction_amount=>@loyalty_purchase.purchase_cost,:remarks=>@loyalty_purchase.purchase_type,
          #                                         :loyalty_transaction_id=>@loyalty_purchase.id,:loyalty_transaction_type=>'LoyaltyPurchase'})
        format.html { redirect_to @loyalty_purchase, notice: 'Loyalty purchase was successfully created.' }
        format.json { render json: @loyalty_purchase, status: :created, location: @loyalty_purchase }
      else
        format.html { render action: "new" }
        format.json { render json: @loyalty_purchase.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /loyalty_purchases/1
  # PATCH/PUT /loyalty_purchases/1.json
  def update
    @loyalty_purchase = LoyaltyPurchase.find(params[:id])

    respond_to do |format|
      if @loyalty_purchase.update_attributes(loyalty_purchase_params)
        format.html { redirect_to @loyalty_purchase, notice: 'Loyalty purchase was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @loyalty_purchase.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /loyalty_purchases/1
  # DELETE /loyalty_purchases/1.json
  def destroy
    @loyalty_purchase = LoyaltyPurchase.find(params[:id])
    @loyalty_purchase.destroy

    respond_to do |format|
      format.html { redirect_to loyalty_purchases_url }
      format.json { head :no_content }
    end
  end

  private
    def day_to_date
      validity_days = params[:loyalty_purchase][:loyalty_credit_transaction_attributes][:validity].to_i
      params[:loyalty_purchase][:loyalty_credit_transaction_attributes][:validity] = validity_days.days.from_now.end_of_day + current_user.unit.unit_detail.options[:day_closing_time].to_i.hours
    end
    def loyalty_purchase_params
      params.require(:loyalty_purchase).permit(:card_identity,:purchase_cost, :purchase_type, loyalty_credit_transaction_attributes: [:validity,:refundable])
    end
end
