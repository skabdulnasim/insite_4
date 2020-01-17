class CancelationPoliciesController < ApplicationController
  # GET /cancelation_policies
  # GET /cancelation_policies.json
  def index
    @cancelation_policies = CancelationPolicy.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cancelation_policies }
    end
  end

  # GET /cancelation_policies/1
  # GET /cancelation_policies/1.json
  def show
    @cancelation_policy = CancelationPolicy.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cancelation_policy }
    end
  end

  # GET /cancelation_policies/new
  # GET /cancelation_policies/new.json
  def new
    @cancelation_policy = CancelationPolicy.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cancelation_policy }
    end
  end

  # GET /cancelation_policies/1/edit
  def edit
    @cancelation_policy = CancelationPolicy.find(params[:id])
  end

  # POST /cancelation_policies
  # POST /cancelation_policies.json
  def create
    @cancelation_policy = CancelationPolicy.new(params[:cancelation_policy])
    _existing_c_p = CancelationPolicy.find_by_unit_id(params[:cancelation_policy][:unit_id])
    _existing_c_p.destroy if _existing_c_p.present?

    respond_to do |format|
      if @cancelation_policy.save
        format.html { redirect_to @cancelation_policy, notice: 'Cancelation policy was successfully created.' }
        format.json { render json: @cancelation_policy, status: :created, location: @cancelation_policy }
      else
        format.html { render action: "new" }
        format.json { render json: @cancelation_policy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cancelation_policies/1
  # PATCH/PUT /cancelation_policies/1.json
  def update
    @cancelation_policy = CancelationPolicy.find(params[:id])

    respond_to do |format|
      if @cancelation_policy.update_attributes(params[:cancelation_policy])
        format.html { redirect_to @cancelation_policy, notice: 'Cancelation policy was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cancelation_policy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cancelation_policies/1
  # DELETE /cancelation_policies/1.json
  def destroy
    @cancelation_policy = CancelationPolicy.find(params[:id])
    @cancelation_policy.destroy

    respond_to do |format|
      format.html { redirect_to cancelation_policies_url }
      format.json { head :no_content }
    end
  end

  def delete_cancelation_cause
    @cancelation_cause = CancelationCause.find(params[:cancelation_cause_id])
    @cancelation_cause.destroy if @cancelation_cause.present?
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def cancelation_policy_params
      params.require(:cancelation_policy).permit(:cancelation_charge, :cancelation_charge_type, :cancelation_not_allowed_state, :cancellation_allowed, :is_delivery_charge_refandable, :is_refundable, :plolicy, :refund_in, :unit_id, :cancelation_allowed_since_deliverable)
    end
end
