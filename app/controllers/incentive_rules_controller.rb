class IncentiveRulesController < ApplicationController
  # GET /incentive_rules
  # GET /incentive_rules.json
  def index
    @incentive_rules = IncentiveRule.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @incentive_rules }
    end
  end

  # GET /incentive_rules/1
  # GET /incentive_rules/1.json
  def show
    @incentive_rule = IncentiveRule.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @incentive_rule }
    end
  end

  # GET /incentive_rules/new
  # GET /incentive_rules/new.json
  def new
    @incentive_rule = IncentiveRule.new
    @roles = Role.all
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @incentive_rule }
    end
  end

  # GET /incentive_rules/1/edit
  def edit
    @incentive_rule = IncentiveRule.find(params[:id])
    @roles = Role.all
  end

  # POST /incentive_rules
  # POST /incentive_rules.json
  def create
    begin
      @incentive_rule = IncentiveRule.new(incentive_rule_params)
      respond_to do |format|
        if @incentive_rule.save
          format.html { redirect_to incentive_rules_url, notice: 'Incentive rule was successfully created.' }
          format.json { render json: @incentive_rule, status: :created, location: @incentive_rule }
        else
          format.html { render action: "new" }
          format.json { render json: @incentive_rule.errors, status: :unprocessable_entity }
        end
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to incentive_rules_path, alert: e.message.to_s
    end
  end

  # PATCH/PUT /incentive_rules/1
  # PATCH/PUT /incentive_rules/1.json
  def update
    begin
      @incentive_rule = IncentiveRule.find(params[:id])

      respond_to do |format|
        if @incentive_rule.update_attributes(incentive_rule_params)
          format.html { redirect_to incentive_rules_url, notice: 'Incentive rule was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @incentive_rule.errors, status: :unprocessable_entity }
        end
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to incentive_rules_path, alert: e.message.to_s
    end
  end

  # DELETE /incentive_rules/1
  # DELETE /incentive_rules/1.json
  def destroy
    @incentive_rule = IncentiveRule.find(params[:id])
    @incentive_rule.destroy

    respond_to do |format|
      format.html { redirect_to incentive_rules_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def incentive_rule_params
      params.require(:incentive_rule).permit(:achivement_lower_range, :achivement_range_type, :achivement_upper_range, :incentive_amount, :role_id, :avg_incentive_amount)
    end
end
