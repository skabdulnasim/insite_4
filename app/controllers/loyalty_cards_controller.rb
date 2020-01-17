class LoyaltyCardsController < ApplicationController
  layout "material"

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  before_filter :set_module_details
  before_filter :set_loyalty_card, only: [:show]

  # GET /loyalty_cards
  # GET /loyalty_cards.json

  def index
    @loyalty_cards = LoyaltyCard.order("id desc")
    @loyalty_cards = @loyalty_cards.find_card(params[:card_identity]) if params[:card_identity]

    smart_listing_create :loyalty_cards, @loyalty_cards, partial: "loyalty_cards/loyalty_smartlist"
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @loyalty_cards }
    end
  end

  # GET /loyalty_cards/1
  # GET /loyalty_cards/1.json
  def show
    #@loyalty_card = LoyaltyCard.find(params[:id])
    @transactions = @loyalty_card.loyalty_card_transactions.includes(:loyalty_transaction)
    smart_listing_create :transactions, @transactions, partial: "loyalty_cards/transaction_listing", default_sort: {created_at: "desc"}

    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.json { render json: @loyalty_card }
    end
  end

  # GET /loyalty_cards/new
  # GET /loyalty_cards/new.json
  def new
    @loyalty_card = LoyaltyCard.new
    @loyalty_card_class = LoyaltyCardClass.all
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @loyalty_card }
    end
  end

  # GET /loyalty_cards/1/edit
  def edit
    @loyalty_card = LoyaltyCard.find(params[:id])
  end

  # POST /loyalty_cards
  # POST /loyalty_cards.json
  def create
    @loyalty_card = LoyaltyCard.new(loyalty_card_params)

    respond_to do |format|
      if @loyalty_card.save
        format.html { redirect_to "/loyalty_cards/#{@loyalty_card.card_no}", notice: 'Loyalty card was successfully created.' }
        format.json { render json: @loyalty_card, status: :created, location: @loyalty_card }
      else
        format.html { render action: "new" }
        format.json { render json: @loyalty_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /loyalty_cards/1
  # PATCH/PUT /loyalty_cards/1.json
  def update
    @loyalty_card = LoyaltyCard.find(params[:id])

    respond_to do |format|
      if @loyalty_card.update_attributes(loyalty_card_params)
        format.html { redirect_to "/loyalty_cards/#{@loyalty_card.card_no}", notice: 'Loyalty card was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @loyalty_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /loyalty_cards/1
  # DELETE /loyalty_cards/1.json
  def destroy
    @loyalty_card = LoyaltyCard.find(params[:id])
    @loyalty_card.destroy

    respond_to do |format|
      format.html { redirect_to loyalty_cards_url }
      format.json { head :no_content }
    end
  end

  private
    def set_loyalty_card
      @loyalty_card = LoyaltyCard.find_card(params[:id]).first
    end

  def set_module_details
    @module_id = "loyalty_cards"
    @module_title = "Loyalty Cards"
  end
    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def loyalty_card_params
      params.require(:loyalty_card).permit(:card_no,:loyalty_card_class_id, :card_serial, :card_type, :customer_id, :name_on_card, :points, :status, :valid_from, :valid_till)
    end
end
