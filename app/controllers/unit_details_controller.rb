class UnitDetailsController < ApplicationController
  load_and_authorize_resource
  require 'json'

  layout "material"

  before_filter :set_module_details
  # GET /unit_details
  # GET /unit_details.json
  def index
    @unit_details = UnitDetail.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @unit_details }
    end
  end

  # GET /unit_details/1
  # GET /unit_details/1.json
  def show
    @unit_detail = UnitDetail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @unit_detail }
    end
  end

  # GET /unit_details/new
  # GET /unit_details/new.json
  def new
    @current_unit = Unit.find(current_user.unit_id)
    @unit_detail = UnitDetail.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @unit_detail }
    end
  end

  # GET /unit_details/1/edit
  def edit
    @unit_detail = UnitDetail.find(params[:id])
  end

  # POST /unit_details
  # POST /unit_details.json
  def create
    UnitTypeOfCusine.save_unit_cusine(current_user.unit_id, params[:cuisine_type])
    UnitAtmosphere.save_unit_atmosphere(current_user.unit_id, params[:atmosphere])
    UnitOutletType.save_unit_outlet(current_user.unit_id, params[:outlet_type])
    UnitMoreInfo.save_unit_more_info(current_user.unit_id, params[:more_info])
    if params[:free_home_delevery].present?
      @unit_detail = UnitDetail.save_unit_details(params[:free_home_delevery],
        params[:min_order_amount],params[:daily_sales_target],
        params[:payment_options],params[:reservation],params[:cuisine_type],
        params[:atmosphere],params[:more_info],params[:outlet_type],params[:open_from],
        params[:open_to],params[:resturant_time_slot],params[:day_closing_time],
        current_user,params[:bill_footer],params[:bill_header], params[:paynear_merchant_api_key],
        params[:paynear_partner_api_key],params[:gst_code],params[:delivery_charges],params[:averages_cost],
        params[:on_line_order],params[:cancellation_allowed],
        params[:cancellation_allowed_since],params[:cancellation_refund],
        params[:table_reservation_timings],params[:min_book_charge_for_two_table_on_week_days],
        params[:min_book_charge_for_two_table_on_weekend_days],params[:min_book_charge_for_two_table_on_special_days],
        params[:maximum_advance_days_allowed_for_reservation],params[:reservation_cancellation_allowed_without_charge],
        params[:reservation_cancellation_allowed],params[:refund_dates], params[:order_sms_unit_name],
        params[:bill_tax_details], params[:tin_number], params[:preauth], params[:reservation_confirmation_without_charge], params[:days_for_confirmation_of_reservation_without_charge], params[:preauth_percentage_for_order],
        params[:access_token], params[:environment], params[:merchant_id], params[:public_key], params[:private_key], params[:day_allow_for_future_order],params[:week_start_day],params[:day_allow_for_order_slot],params[:standard_delivery_time],params[:pan_no],params[:slot_applicable_from],params[:bill_suffix],params[:bill_prefix])

    else
      @unit_detail = UnitDetail.save_unit_details("Not available", "600", "1000","", "No", "", "", "","","09:00 AM" ,"09:00 PM" ,"60",0,
        current_user, "", "", "", "",
        "" ,"", "", "No", "No", "", "", "",
        "", "", "", "", "", "No", "", "", "", "", "", 0, "Yes", 0, 0, "", "", "", "", "", 0,"Sunday",0,0,"Today","","")
    end
    respond_to do |format|
      if @unit_detail.save
        format.html { redirect_to new_unit_detail_path, notice: 'Branch details updated.' }
        format.json { render json: @unit_detail, status: :created, location: @unit_detail }
      else
        format.html { render action: "new" }
        format.json { render json: @unit_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /unit_details/1
  # PUT /unit_details/1.json
  def update
    @unit_detail = UnitDetail.find(params[:id])

    respond_to do |format|
      if @unit_detail.update_attributes(params[:unit_detail])
        format.html { redirect_to @unit_detail, notice: 'Unit detail was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: new_unit_detail_path }
        format.json { render json: @unit_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /unit_details/1
  # DELETE /unit_details/1.json
  def destroy
    @unit_detail = UnitDetail.find(params[:id])
    @unit_detail.destroy

    respond_to do |format|
      format.html { redirect_to unit_details_url }
      format.json { head :no_content }
    end
  end

  private

  def set_module_details
    @module_id = "units"
    @module_title = "Organization"
  end
end