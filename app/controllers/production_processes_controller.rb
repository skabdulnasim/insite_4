class ProductionProcessesController < ApplicationController

  include SmartListing::Helper::ControllerExtensions
  helper SmartListing::Helper

  # GET /production_processes
  # GET /production_processes.json
  def index
    @categories = Category.all
    @production_processes = ProductionProcess.order("id asc")
    @production_processes = @production_processes.filter_by_string(params[:process_filter]) if params[:process_filter].present?
    smart_listing_create :production_processes, @production_processes, partial: "production_processes/production_processes_smartlist", default_sort: {id: "desc"}
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @production_processes }
      format.js #index.js.erb
    end
  end

  # GET /production_processes/1
  # GET /production_processes/1.json
  def show
    @production_process = ProductionProcess.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @production_process }
    end
  end

  # GET /production_processes/new
  # GET /production_processes/new.json
  def new
    @production_process = ProductionProcess.new
    @basic_units = ProductBasicUnit.all
    @conjugated_units =ConjugatedUnit.all
    @physical_types = PhysicalType.all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @production_process }
    end
  end

  # GET /production_processes/1/edit
  def edit
    @production_process = ProductionProcess.find(params[:id])
    @basic_units = ProductBasicUnit.all
    @conjugated_units =ConjugatedUnit.all
    @physical_types = PhysicalType.all
  end

  # POST /production_processes
  # POST /production_processes.json
  def create
    @production_process = ProductionProcess.new(production_process_params)

    respond_to do |format|
      if @production_process.save
        format.html { redirect_to @production_process, notice: 'Production process was successfully created.' }
        format.json { render json: @production_process, status: :created, location: @production_process }
      else
        format.html { render action: "new" }
        format.json { render json: @production_process.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /production_processes/1
  # PATCH/PUT /production_processes/1.json
  def update
    @production_process = ProductionProcess.find(params[:id])

    respond_to do |format|
      if @production_process.update_attributes(production_process_params)
        format.html { redirect_to @production_process, notice: 'Production process was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @production_process.errors, status: :unprocessable_entity }
      end
    end
  end

  def toggle_trash
    @production_process = ProductionProcess.find(params[:id])
    _status = @production_process.is_trashed == false ? true : false
    @production_process.update_attributes(:is_trashed => _status)
    respond_to do |format|
      format.html { redirect_to production_processes_url, notice: 'Process was successfully updated.' }
      format.json { head :no_content }
    end
  end

  # DELETE /production_processes/1
  # DELETE /production_processes/1.json
  def destroy
    @production_process = ProductionProcess.find(params[:id])
    @production_process.destroy

    respond_to do |format|
      format.html { redirect_to production_processes_url, notice: 'Process was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def production_process_params
      params.require(:production_process).permit(:category_id, :cost, :local_name, :name, :short_name, :process_image)
    end
end
