class ReservationReportsController < ApplicationController
  layout "material"
  
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  include SaleReportsHelper

  before_filter :set_module_details


  def index
    _units = Bill.select("DISTINCT(unit_id)")
    @units = Unit.order(unit_name: :asc).get_unit_name(_units)
    respond_to do |format|
      format.html
    end
  end

  def reservation_report
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @unit = Unit.find(@unit_id)
    _resources = Reservation.pluck(:resource_id).uniq
    @resources = Resource.get_resource_name(_resources)
    @reservations = Reservation.by_date(params[:from_date]).by_unit(@unit_id).order('resource_id asc')
    @reservations = @reservations.by_resource(params[:resource_id]) if params[:resource_id].present?
    smart_listing_create :reservation_report, @reservations, partial: "reservation_reports/reservation_report"
    respond_to do |format|
      format.html
      format.js
      format.csv { send_data Reservation.reservation_report_csv(@reservations), filename: "reservation_report-#{params[:from_date]}.csv" }    
    end
  end

  private
  def set_module_details
    @module_id = "reports"
    @module_title = "Reservation Report"
  end

  
end