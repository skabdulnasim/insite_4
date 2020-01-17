class ReturnPoliciesController < ApplicationController
  # GET /return_policies
  # GET /return_policies.json
  def index
    @return_policies = ReturnPolicy.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @return_policies }
    end
  end

  # GET /return_policies/1
  # GET /return_policies/1.json
  def show
    @return_policy = ReturnPolicy.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @return_policy }
    end
  end

  # GET /return_policies/new
  # GET /return_policies/new.json
  def new
    @return_policy = ReturnPolicy.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @return_policy }
    end
  end

  # GET /return_policies/1/edit
  def edit
    @return_policy = ReturnPolicy.find(params[:id])
  end

  # POST /return_policies
  # POST /return_policies.json
  def create
    @return_policy = ReturnPolicy.new(params[:return_policy])
    _existing_r_p = ReturnPolicy.find_by_unit_id(params[:return_policy][:unit_id])
    _existing_r_p.destroy if _existing_r_p.present?

    respond_to do |format|
      if @return_policy.save
        format.html { redirect_to @return_policy, notice: 'Return policy was successfully created.' }
        format.json { render json: @return_policy, status: :created, location: @return_policy }
      else
        format.html { render action: "new" }
        format.json { render json: @return_policy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /return_policies/1
  # PATCH/PUT /return_policies/1.json
  def update
    @return_policy = ReturnPolicy.find(params[:id])

    respond_to do |format|
      if @return_policy.update_attributes(params[:return_policy])
        format.html { redirect_to @return_policy, notice: 'Return policy was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @return_policy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /return_policies/1
  # DELETE /return_policies/1.json
  def destroy
    @return_policy = ReturnPolicy.find(params[:id])
    @return_policy.destroy

    respond_to do |format|
      format.html { redirect_to return_policies_url }
      format.json { head :no_content }
    end
  end

  def delete_return_cause
    @return_cause = ReturnCause.find(params[:return_cause_id])
    @return_cause.destroy if @return_cause.present?
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def return_policy_params
      params.require(:return_policy).permit(:is_delivery_charge_refandable, :is_delivery_charge_refandable, :is_refundable, :policy, :return_allowed, :return_allowed_after_deliverable, :return_alowed_on_order_state, :return_charge, :return_charge_type, :unit_id)
    end
end
