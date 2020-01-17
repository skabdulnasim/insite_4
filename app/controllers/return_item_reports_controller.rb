class ReturnItemReportsController < ApplicationController
  layout "material"
  
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  include SaleReportsHelper

  before_filter :set_module_details
  before_filter :set_timerange, only: [:by_date, :refund_report]
	
	def index
	end

	def by_date
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @unit = Unit.find(@unit_id)
		@return_items = ReturnItem.by_date_range(@from_datetime,@to_datetime)
    smart_listing_create :return_by_date, @return_items, partial: "return_item_reports/return_by_date_smartlist"
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.pdf { render :layout => false } # Add this line
      format.csv { send_data ReturnItem.by_date_return_item_reports_to_csv(current_user.unit_id,@unit_id,@return_items,@from_datetime,@to_datetime), filename: "return_item_reports-of-#{params[:from_date]}.csv" }    
  	end
  end

  def refund_report
    @money_refunds = MoneyRefund.by_date_range(@from_datetime,@to_datetime)
    smart_listing_create :refund_by_date, @money_refunds, partial: "return_item_reports/refund_by_date_smartlist"
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.csv { send_data MoneyRefund.by_date_refund_report_to_csv(@money_refunds,@from_datetime,@to_datetime), filename: "refund-report-of-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end
  end

  private
  def set_module_details
    @module_id = "reports"
    @module_title = "Return Report"
  end 

end
