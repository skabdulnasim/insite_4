# CREATED BY ABDUL
class VoidReportsController < ApplicationController
	layout "material"
  
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  # before_filter :set_module_details
  # before_filter :set_timerange, only: [:by_date, :by_date_range, :category_wise]

  def index
    _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    # @menu_cards = MenuCard.set_mode(1).set_unit(_unit_id).not_trashed
   	_units = Bill.select("DISTINCT(unit_id)")
    @units = Unit.order(unit_name: :asc).get_unit_name(_units)
    respond_to do |format|
      format.html
      # format.json { render json: @menu_cards }
    end
  end

  def by_date
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @unit = Unit.find(@unit_id)
    @sales = Bill.unit_bills(@unit_id).order("id asc").void_bill
    @sales = @sales.by_recorded_at(params[:from_date],params[:to_date]) if params[:from_date].present?
    smart_listing_create :void_sales_by_date, @sales, partial: "void_reports/void_sales_by_date_smartlist",default_sort: {recorded_at: "asc"}
    respond_to do |format|
      format.html # index.html.erb
      # format.js
      # format.csv { send_data Bill.invalid_bill.by_date_nc_to_csv(current_user.unit_id,@unit_id,@sales,@from_datetime,@to_datetime), filename: "nc-report-of-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end
  end
end
