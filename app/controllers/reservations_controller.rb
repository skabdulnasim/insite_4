class ReservationsController < ApplicationController
  load_and_authorize_resource
  layout "material"

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  before_filter :set_module_details
  # GET /reservations
  # GET /reservations.json
  def index
    _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @resources = Resource.all
    @reservations = Reservation.by_unit(_unit_id)
    @customer = Customer.new(params[:customer])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @reservations }
    end
  end

  # GET /reservations/1
  # GET /reservations/1.json
  def show
    @reservation = Reservation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @reservation }
    end
  end

  # GET /reservations/new
  # GET /reservations/new.json
  def new
    @reservation = Reservation.new
    @resources = Resource.all
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @reservation }
    end
  end

  # GET /reservations/1/edit
  def edit
    @reservation = Reservation.find(params[:id])
  end

  # POST /reservations
  # POST /reservations.json
  def create
    begin
      ActiveRecord::Base.transaction do
        _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
        _reservation = Reservation.new
        _reservation[:reservation_date] = params[:reservation_date]
        _reservation[:pax] = params[:pax]
        _reservation[:customer_id] = params[:customer_id]
        _reservation[:resource_id] = params[:resource_id]
        _reservation[:slot_id] = params[:slot_id]
        _reservation[:unit_id] = _unit_id
        _reservation[:start_time] = params[:start_time]
        _reservation[:end_time] = params[:end_time]
        _reservation[:status] = '0'
        _reservation[:customer_mobile] = params[:customer_mobile]
        _reservation[:start_date] = params[:start_date]
        _reservation[:end_date] = params[:end_date]
        _reservation.save
      end
      redirect_to :back, notice: 'Reservation was successfully created.'
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to reservations_path, alert: e.message.to_s
    end

  end

  # PATCH/PUT /reservations/1
  # PATCH/PUT /reservations/1.json
  def update
    @reservation = Reservation.find(params[:id])
    puts params
    respond_to do |format|
      if @reservation.update_attributes(params[:reservation])
        format.html { redirect_to @reservation, notice: 'Reservation was successfully updated.' }
        format.json { render json: @reservation }
        format.js
      else
        format.html { render action: "edit" }
        format.json { render json: @reservation.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /reservations/1
  # DELETE /reservations/1.json
  def destroy
    @reservation = Reservation.find(params[:id])
    @reservation.destroy

    respond_to do |format|
      format.html { redirect_to reservations_url }
      format.json { head :no_content }
    end
  end

  def reservations_list
    @customer = Customer.new(params[:customer])
    _unit_id = params[:unit_id].present? ? params[:unit_id] : @current_user.unit_id
    @resources = Resource.by_unit(_unit_id)
    @reservations = Reservation.by_unit(_unit_id)
    @reservations = @reservations.by_id(params[:id_filter]) if params[:id_filter].present?
    @reservations = @reservations.by_status(params[:billed]) if params[:billed].present?
    @reservations = @reservations.by_resource(params[:resource_ids]) if params[:resource_ids].present?
    @reservations = @reservations.set_slot_in(params[:slot_ids]) if params[:slot_ids].present?
    @reservations = @reservations.by_date(params[:from_date]) if params[:from_date].present?
    smart_listing_create :reservations, @reservations, partial: "reservations/reservations_smartlisting", default_sort: {created_at: "desc"}
    respond_to do |format|
      format.html
      format.js
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def set_module_details
      @module_id = "Reservation"
      @module_title = "Reservations"
    end

    # def reservation_params
    #   params.require(:reservation).permit(:customer, :pax, :reservation_date, :resource, :slot, :bill_id, :status)
    # end
end
