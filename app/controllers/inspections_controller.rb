class InspectionsController < ApplicationController

  before_filter :set_module_details

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  # GET /inspections
  # GET /inspections.json
  def index
    puts "params : #{params}"
    user_unit = current_user.unit
    unit_list = Array.new
    unit_list.push(user_unit.id)
    unit_list.concat(child_units([],user_unit)) #calling the child_units([],obj) to get the child unit list
    @units = Unit.set_id_in(unit_list)
    @inspections = Inspection.by_unit_list(unit_list).set_inspected_entity_type('Resource').order('id desc')
    @inspections = Inspection.by_unit(params[:unit_id]).set_inspected_entity_type('Resource').order('id desc') if params[:unit_id].present?
    @inspections = @inspections.by_date_range(params[:from_date],params[:to_date]) if params[:from_date].present? and params[:to_date].present?
    if params[:user_name].present? 
      @users = User.by_name(params[:user_name])
      _user_ids = @users.uniq.pluck(:id)
      @inspections = @inspections.set_user_in(_user_ids)
    end
    # @inspections = @inspections.joins(:resource).merge(Resource.name_like(params[:resource_name])) if params[:resource_name].present?
    @inspections = @inspections.joins("INNER JOIN resources ON inspections.inspected_entity_id = resources.id").merge(Resource.name_like(params[:resource_name])) if params[:resource_name].present?
    @days = Inspection.uniq.pluck(:day)
  
    smart_listing_create :inspections, @inspections, partial: "inspections/inspections_smartlist",page_sizes:[10]
    respond_to do |format|
      format.js # index.js.erb
      format.html # index.html.erb
      # format.json { render json: @inspections }
      format.json { render json: @users }
    end
  end

  # GET /inspections/1
  # GET /inspections/1.json
  def show
    @inspection = Inspection.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @inspection }
    end
  end

  # GET /inspections/new
  # GET /inspections/new.json
  def new
    @inspection = Inspection.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @inspection }
    end
  end

  # GET /inspections/1/edit
  def edit
    @inspection = Inspection.find(params[:id])
  end

  # POST /inspections
  # POST /inspections.json
  def create
    @inspection = Inspection.new(inspection_params)

    respond_to do |format|
      if @inspection.save
        format.html { redirect_to @inspection, notice: 'Inspection was successfully created.' }
        format.json { render json: @inspection, status: :created, location: @inspection }
      else
        format.html { render action: "new" }
        format.json { render json: @inspection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /inspections/1
  # PATCH/PUT /inspections/1.json
  def update
    @inspection = Inspection.find(params[:id])

    respond_to do |format|
      if @inspection.update_attributes(inspection_params)
        format.html { redirect_to @inspection, notice: 'Inspection was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @inspection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inspections/1
  # DELETE /inspections/1.json
  def destroy
    @inspection = Inspection.find(params[:id])
    @inspection.destroy

    respond_to do |format|
      format.html { redirect_to inspections_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def inspection_params
      params.require(:inspection).permit(:day, :discussion, :latitude, :longitude, :recorded_at, :resource_id, :user_id)
    end

    def set_module_details
      @module_id = "inspections"
      @module_title = "Inspections"
    end
end
