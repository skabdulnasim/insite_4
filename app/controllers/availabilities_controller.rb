class AvailabilitiesController < ApplicationController
  layout "material"
  load_and_authorize_resource
  before_filter :set_module_details
  # GET /availabilities
  # GET /availabilities.json
  def index
    @availabilities = Availability.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @availabilities }
    end
  end

  # GET /availabilities/1
  # GET /availabilities/1.json
  def show
    @availability = Availability.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @availability }
    end
  end

  # GET /availabilities/new
  # GET /availabilities/new.json
  def new
    _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @sections = Section.where(:unit_id => _unit_id)
    @availability = Availability.new
    @slots = Slot.all
    @resources = Resource.all
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @availability }
    end
  end

  # GET /availabilities/1/edit
  def edit
    @availability = Availability.find(params[:id])
  end

  # POST /availabilities
  # POST /availabilities.json
  def create
    begin
      raise 'Selcet at least one resource first.' unless !params[:resources].nil?
      ActiveRecord::Base.transaction do
        params[:resources].each do |resource|
          _availability = Availability.new
          _availability[:available_date] = params[:available_date]
          _availability[:slot_id] = params[:slot]
          _availability[:resource_id] = resource
          _availability.save
        end
      end
      redirect_to availabilities_path, notice: 'Availability was successfully created.'
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to availabilities_path, alert: e.message.to_s
    end
  end

  # PATCH/PUT /availabilities/1
  # PATCH/PUT /availabilities/1.json
  def update
    @availability = Availability.find(params[:id])

    respond_to do |format|
      if @availability.update_attributes(availability_params)
        format.html { redirect_to @availability, notice: 'Availability was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @availability.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /availabilities/1
  # DELETE /availabilities/1.json
  def destroy
    @availability = Availability.find(params[:id])
    @availability.destroy

    respond_to do |format|
      format.html { redirect_to availabilities_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def set_module_details
      @module_id = "availabilities"
      @module_title = "Availabilities"
    end

    def availability_params
      params.require(:availability).permit(:available_date, :resource, :slot)
    end
end
