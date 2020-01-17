class LoyaltyReportsController < ApplicationController
  layout "material"

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  before_filter :set_module_details
  before_filter :set_timerange, only: [:by_date, :loyalty_point_use, :membership_points_accumulation]

  def index
  end

  def by_date
    @sells_scope = LoyaltyCreditTransaction.check_reward_report_date_range(@from_datetime,@to_datetime) if params[:from_date].present?
    smart_listing_create :sales_loyalty_card_wise, @sells_scope, partial: "loyalty_reports/sales_loyalty_card_wise_smartlist",array: true
    respond_to do |format|
      format.html 
      format.js
      format.csv { send_data LoyaltyCreditTransaction.loyalty_card_report_to_csv(@sells_scope), filename: "loyalty-reward-report-of-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end 
  end

  def loyalty_point_use
    #@loyalty_scope = LoyaltyCardTransaction.by_created_at(@from_datetime,@to_datetime).uniq.pluck(:loyalty_card_id) if params[:from_date].present?
    @loyalty_scope = LoyaltyCreditTransaction.select("loyalty_card_id, sum(obtained_point) as total_obtained_point, sum(available_point) as total_available_point").group("loyalty_card_id").by_created_at(@from_datetime,@to_datetime).remarks_recharge if params[:from_date].present?
    smart_listing_create :loyalty_card_use, @loyalty_scope, partial: "loyalty_reports/loyalty_card_use_smartlist",array: true
    respond_to do |format|
      format.html 
      format.js
      format.csv { send_data LoyaltyCardTransaction.loyalty_card_use_report_to_csv(@loyalty_scope,@from_datetime,@to_datetime), filename: "loyalty-card-details-report-of-#{params[:from_date]}-to-#{params[:to_date]}.csv" }      
    end 
  end

  def membership_points_accumulation
    #@loyalty_scope = LoyaltyCreditTransaction.by_created_at(@from_datetime,@to_datetime).remarks_reward.uniq.pluck(:loyalty_card_id) if params[:from_date].present?
    @loyalty_scope = LoyaltyCreditTransaction.select("loyalty_card_id, sum(obtained_point) as total_obtained_point, sum(available_point) as total_available_point").group("loyalty_card_id").by_created_at(@from_datetime,@to_datetime).remarks_reward if params[:from_date].present?
    smart_listing_create :membership_points, @loyalty_scope, partial: "loyalty_reports/membership_points_smartlist",array: true    
    respond_to do |format|
      format.html 
      format.js
      format.csv { send_data LoyaltyCreditTransaction.loyalty_card_points_accumulation_to_csv(@loyalty_scope), filename: "loyalty-card-points-accumulation-of-#{params[:from_date]}-to-#{params[:to_date]}.csv" }      
    end 
  end

  def set_module_details
    @module_id = "reports"
    @module_title = "Loyalty Report"
  end  

end