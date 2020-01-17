class CommissionRulesController < ApplicationController

	# before_filter :set_resource, only: [:new, :create, :show, :update]
	include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  # GET /commission_rules
  # GET /commission_rules.json
  def index
    @commission_rules = CommissionRule.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @commission_rules }
    end
  end

  # GET /commission_rules/1
  # GET /commission_rules/1.json
  def show
    @commission_rule = CommissionRule.find(params[:id])
    @resource = Resource.find(params[:resource_id])
    @commission_rule_products = @commission_rule.commission_rule_inputs.order('id asc')
    smart_listing_create :commission_rule_products, @commission_rule_products, partial: "commission_rules/commission_rule_products_smartlist", default_sort: {created_at: "desc"}, page_sizes: [10]

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @commission_rule }
      format.js
    end
  end

  # GET /commission_rules/new
  # GET /commission_rules/new.json
  def new
    @commission_rule = CommissionRule.new
    @resource = Resource.find(params[:resource_id])
    product_scope = Product.get_all

    smart_listing_create :products, product_scope, partial: "products_smartlist", default_sort: {id: "desc"}

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @commission_rule }
      format.js
    end
  end

  # GET /commission_rules/1/edit
  def edit
    @commission_rule = CommissionRule.find(params[:id])
  end

  # POST /commission_rules
  # POST /commission_rules.json
  def create
    puts params
    begin
      ActiveRecord::Base.transaction do # Protective transaction block
        @resource = Resource.find(params[:commission_rule][:resource_id])
        raise "Please select months." unless params[:select_months].present?
        params[:select_months].each do |selected_month|
          commission_rules = CommissionRule.by_resource(params[:commission_rule][:resource_id]).by_month(selected_month)
          if commission_rules.present?
            commission_rule_id = commission_rules.first.id
            params[:commission_rule][:commission_rule_inputs_attributes].each do |cri|
              commission_rule_input = CommissionRuleInput.find_by_product_id_and_commission_rule_id(cri[1]["product_id"],commission_rule_id)
              if commission_rule_input.present?
                commission_rule_output = CommissionRuleOutput.find_by_commission_rule_input_id_and_commission_rule_id(commission_rule_input.id,commission_rule_id)
                commission_rule_output.update_attributes(:amount=> cri[1]["commission_rule_output_attributes"]["csm_commission_amount"].to_f + cri[1]["commission_rule_output_attributes"]["owner_commission_amount"].to_f, :amount_type=> cri[1]["commission_rule_output_attributes"]["amount_type"], :owner_commission_amount=> cri[1]["commission_rule_output_attributes"]["owner_commission_amount"], :csm_commission_amount=> cri[1]["commission_rule_output_attributes"]["csm_commission_amount"])
              else
                cri[1]["commission_rule_id"] = commission_rule_id.to_i
                @commission_rule_input = CommissionRuleInput.new(cri[1])
                @commission_rule_input.save
              end
            end
          else
            @commission_rule = CommissionRule.new(params[:commission_rule])
            @commission_rule.month = selected_month
            @commission_rule.save
          end
        end
        respond_to do |format|
          format.html { redirect_to resource_path(@resource), notice: 'Commission rule added successfully.' }
        end
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to new_resource_commission_rule_path(@resource), alert: e.message
    end
  end

  # PATCH/PUT /commission_rules/1
  # PATCH/PUT /commission_rules/1.json
  def update
    @commission_rule = CommissionRule.find(params[:id])

    respond_to do |format|
      if @commission_rule.update_attributes(commission_rule_params)
        format.html { redirect_to @commission_rule, notice: 'Commission rule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @commission_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /commission_rules/1
  # DELETE /commission_rules/1.json
  def destroy
    @commission_rule = CommissionRule.find(params[:id])
    @commission_rule.destroy

    respond_to do |format|
      format.html { redirect_to commission_rules_url }
      format.json { head :no_content }
    end
  end

  def quick_update
    begin
      @commission_rule_output = CommissionRuleOutput.find(params[:rule_output_id])
      product_id = @commission_rule_output.commission_rule_input.product_id
      month = @commission_rule_output.commission_rule.month
      resource_id = @commission_rule_output.commission_rule.resource_id
      owner_commission = params[:owner_commission].present? ? params[:owner_commission] : 0
      csm_commission = params[:csm_commission].present? ? params[:csm_commission] : 0
      @commission_rule_output.update_attributes(:owner_commission_amount => owner_commission, :csm_commission_amount => csm_commission, :amount => owner_commission.to_f + csm_commission.to_f)
      respond_to do |format|
        format.json { render json: @commission_rule_output }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      respond_to do |format|
        format.json { render json: {:error=> e.message.to_s}, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use this method to whitelist the permissible parameters. Example:
  # params.require(:person).permit(:name, :age)
  # Also, you can specialize this method with per-user checking of permissible attributes.
  def commission_rule_params
    params.require(:commission_rule).permit(:month, :resource_id, :set_by)
  end
end