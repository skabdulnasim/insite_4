class BohReportsController < ApplicationController
  layout "material"
  
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  include SaleReportsHelper

  before_filter :set_module_details
  before_filter :set_timerange, only: [:by_date_boh]
  def index
  	_units = Bill.select("DISTINCT(unit_id)")
    @units = Unit.get_unit_name(_units).order("unit_name asc")
    respond_to do |format|
      format.html
      format.json { render json: @menu_cards }
    end
  end

  def by_date_boh
  	@unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
  	@bills = Bill.unit_bills(@unit_id).valid_bill.boh_bill.by_recorded_at(@from_datetime,@to_datetime).order("recorded_at asc")
    smart_listing_create :boh_sales_by_date, @bills, partial: "boh_reports/boh_sales_smartlisting",default_sort: {recorded_at: "asc"}
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.pdf { render :layout => false } # Add this line
      format.csv { send_data by_date_boh_sales_to_csv(@bills), filename: "boh-sales-report-of-#{params[:from_date]}.csv" }    
    end
  end

  private
  def set_module_details
    @module_id = "reports"
    @module_title = "Boh Report"
  end 

  def by_date_boh_sales_to_csv(_bills)
    
  end
end
