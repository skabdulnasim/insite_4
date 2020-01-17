class QuotationsController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  
  def index
    @quotations = Quotation.reverse
    #@quotations = @quotations.by_customer(params(:id_filter)) if params[:id_filter].present?
    @quotations = @quotations.by_customer_identity(params[:id_filter]) if params[:id_filter].present?
    smart_listing_create :quotations, @quotations, partial: "quotations/quotations_smartlist"
    respond_to do |format|
      format.js
      format.html
    end
  end

  def show
    @quotation = Quotation.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @quotation.to_json(:include=>[:advance_payments,:orders]) }
    end
  end
end
