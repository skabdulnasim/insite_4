class KotReportsController < ApplicationController
  layout "material"

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  before_filter :set_module_details
  before_filter :set_timerange, only: [:void_kot_report]

  def index
    _units = Bill.select("DISTINCT(unit_id)")
    @units = Unit.order(unit_name: :asc).get_unit_name(_units)
    respond_to do |format|
      format.html
    end
  end

  def void_kot_report
    unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @kot_scope = OrderDetail.set_unit(unit_id).by_date_range(@from_datetime,@to_datetime).cancel_item if params[:from_date].present?
    smart_listing_create :void_kot, @kot_scope, partial: "kot_reports/void_kot_smartlist",array: true
    respond_to do |format|
      format.html 
      format.js
      format.csv { send_data OrderDetail.void_kot_report_to_csv(@kot_scope), filename: "void_kot_report-of-#{params[:from_date]}-to-#{params[:to_date]}.csv" }      
    end 
  end

  def set_module_details
    @module_id = "reports"
    @module_title = "KOT Report"
  end  

end