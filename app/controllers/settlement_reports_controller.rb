class SettlementReportsController < ApplicationController
  layout "material"

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  before_filter :set_module_details
  before_filter :set_timerange, only: [:card_wise, :loyalty_card_wise]

  def index
    _units = Bill.select("DISTINCT(unit_id)")
    @units = Unit.get_unit_name(_units)
  end

  def card_wise
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @sells_scope = Settlement.get_card_wise_report(@unit_id,params)
    smart_listing_create :sales_card_wise, @sells_scope, partial: "settlement_reports/sales_card_wise_smartlist",array: true
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.csv { send_data Settlement.get_card_wise_report_to_csv(@unit_id,@sells_scope), filename: "card-report-of-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end    
  end

  def loyalty_card_wise
    @sells_scope = LoyaltyCardPayment.check_redeem_report_date_range(@from_datetime,@to_datetime) if params[:from_date].present?
    smart_listing_create :sales_loyalty_card_wise, @sells_scope, partial: "settlement_reports/sales_loyalty_card_wise_smartlist",array: true
    respond_to do |format|
      format.html 
      format.js
      format.csv { send_data LoyaltyCardPayment.loyalty_card_report_to_csv(@sells_scope), filename: "loyalty-redeem-report-of-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end 
  end

  def set_module_details
    @module_id = "reports"
    @module_title = "Settlement Report"
  end  

end