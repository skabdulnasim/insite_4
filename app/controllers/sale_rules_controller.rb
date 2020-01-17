class SaleRulesController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  # GET /sale_rules
  # GET /sale_rules.json
  def index
    @sale_rules = SaleRule.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sale_rules }
    end
  end

  # GET /sale_rules/1
  # GET /sale_rules/1.json
  def show
    @sale_rule = SaleRule.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sale_rule }
    end
  end

  # GET /sale_rules/new
  # GET /sale_rules/new.json
  def new
    @menu_cards = MenuCard.set_unit(current_user.unit_id).active.not_trashed
    @sale_rule = SaleRule.new
    @sale_rule_imput = @sale_rule.build_sale_rule_input
    @sale_rule_output = @sale_rule.build_sale_rule_output
    @menu_card = MenuCard.set_unit(current_user.unit_id).active.not_trashed.first
    @menu_card = MenuCard.find(params[:menu_card]) if params[:menu_card].present?
    @menu_card_products = @menu_card.menu_products.order("menu_category_id asc")
    @menu_card_products = @menu_card_products.filter_by_string(params[:filter]) if params[:filter].present?
    smart_listing_create :menu_card_products, @menu_card_products, partial: "sale_rules/menu_card_product_smartlist", default_sort: {created_at: "desc"}
    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @sale_rule }
    end
  end

  # GET /sale_rules/1/edit
  def edit
    @sale_rule = SaleRule.find(params[:id])
    @menu_cards = MenuCard.set_unit(current_user.unit_id).active.not_trashed
    @menu_card = @sale_rule.menu_products.present? ? @sale_rule.menu_products.first.menu_card : MenuCard.set_unit(current_user.unit_id).active.not_trashed.first
    @menu_card = MenuCard.find(params[:menu_card]) if params[:menu_card].present?
    @menu_card_products = @menu_card.menu_products.order("menu_category_id asc")
    @menu_card_products = @menu_card_products.filter_by_string(params[:filter]) if params[:filter].present?
    smart_listing_create :menu_card_products, @menu_card_products, partial: "sale_rules/menu_card_product_smartlist", default_sort: {created_at: "desc"}
    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end

  # POST /sale_rules
  # POST /sale_rules.json
  def create
    @sale_rule = SaleRule.new(params[:sale_rule])
    respond_to do |format|
      if @sale_rule.save
        if params[:selected_menu_products].present?
          params[:selected_menu_products].each do |mp_id|
            MenuProductSaleRule.create(:menu_product_id => mp_id, :sale_rule_id => @sale_rule.id, :menu_card_id => params[:selected_menu_card])
          end
        end
        format.html { redirect_to @sale_rule, notice: 'Sale rule was successfully created.' }
        format.json { render json: @sale_rule, status: :created, location: @sale_rule }
      else
        format.html { render action: "new" }
        format.json { render json: @sale_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sale_rules/1
  # PATCH/PUT /sale_rules/1.json
  def update
    @sale_rule = SaleRule.find(params[:id])

    respond_to do |format|
      if @sale_rule.update_attributes(sale_rule_params)
        if @sale_rule.menu_product_sale_rules.present?
          @sale_rule.menu_product_sale_rules.by_menu_card(params[:selected_menu_card]).destroy_all
        end
        if params[:selected_menu_products].present?
          params[:selected_menu_products].each do |mp_id|
            MenuProductSaleRule.create(:menu_product_id => mp_id, :sale_rule_id => @sale_rule.id, :menu_card_id => params[:selected_menu_card])
          end
        end
        format.html { redirect_to @sale_rule, notice: 'Sale rule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sale_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sale_rules/1
  # DELETE /sale_rules/1.json
  def destroy
    @sale_rule = SaleRule.find(params[:id])
    @sale_rule.destroy

    respond_to do |format|
      format.html { redirect_to sale_rules_url }
      format.json { head :no_content }
    end
  end

  def all_sale_rules
    @all_sale_rules = Array.new
    @sale_rules = SaleRule.active.valid_till
    @sale_rules = @sale_rules.set_sale_rule_type_in(params[:sale_rule_types].split(',')) if params[:sale_rule_types].present?
    @sale_rules = @sale_rules.by_specific_type(params[:specific_type]) if params[:specific_type].present?
    @sale_rules.each do |sale_rule|
      sale_rule_array = {}
      sale_rule_array[:sale_rule] = sale_rule
      sale_rule_array[:checked] = MenuProductSaleRule.by_menu_product(params[:menu_product_id]).pluck(:sale_rule_id).include?(sale_rule.id)
      @all_sale_rules.push sale_rule_array
    end
    respond_to do |format|
      format.json { render json: @all_sale_rules}
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def sale_rule_params
      params.require(:sale_rule).permit(:name, :status, :type, :valid_from, :valid_till)
    end
end
