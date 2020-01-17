class CashHandlingsController < ApplicationController

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  before_filter :set_timerange, only: [:index]
  def index
    _unit_id = params[:unit_id].present? ? params[:unit_id] : @current_user.unit_id
    # @distinct_unit = Pay.find(:all, :conditions => ["unit_id =?",_unit_id] )
    @cash_handlings = Pay.order("id desc")
    @maxpay = Pay.maximum('available_amount')
    @cash_handlings = @cash_handlings.by_unit(_unit_id)
    @cash_handlings = @cash_handlings.set_id(params[:id_filter]) if params[:id_filter].present?
    @cash_handlings = @cash_handlings.check_price_range(params[:from_price],params[:to_price]) if params[:from_price].present? && params[:to_price].present?
    @cash_handlings = @cash_handlings.set_transaction_type_in(params[:transaction_type]) if params[:transaction_type].present?
    @cash_handlings = @cash_handlings.by_recorded_at(@from_datetime,@to_datetime) if params[:from_date].present?
    smart_listing_create :cash_handlings, @cash_handlings, partial: "cash_handlings/cash_handlings_smartlist", default_sort: {created_at: "desc"}
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @cash_handlings }
    end
  end

end


