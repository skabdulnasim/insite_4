class SectionsController < ApplicationController
  load_and_authorize_resource

  layout "material"
  before_filter :set_module_details

  # GET /sections
  # GET /sections.json
  def index
    _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @sections = Section.where(:unit_id => _unit_id)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sections.to_json(:include => {:tax_groups => {:include => :tax_classes}}) }
    end
  end

  # GET /sections/1
  # GET /sections/1.json
  def show
    @section = Section.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @section }
    end
  end

  # GET /sections/new
  # GET /sections/new.json
  def new
    @section = Section.new
    # @thirdparty_configurations = @section.thirdparty_configurations.build
    @owner_will_crud_menu = AppConfiguration.get_config_value('owner_will_crud_menu')
    @master_sections = Unit.find(1).sections
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @section }
    end
  end

  # GET /sections/1/edit
  def edit
    @section = Section.find(params[:id])
    @master_sections = Unit.find(1).sections
    # @thirdparty_configurations = @section.thirdparty_configurations
    # puts @thirdparty_configuration.inspect
    @owner_will_crud_menu = AppConfiguration.get_config_value('owner_will_crud_menu')
  end

  # POST /sections
  # POST /sections.json
  def create
    @section = Section.new(params[:section])
    Section.save_tax_classes(@section, params[:tax_classes]) if params[:tax_classes].present?

    respond_to do |format|
      if @section.save
        format.html { redirect_to sections_path, notice: 'Section was successfully created.' }
        format.json { render json: @section, status: :created, location: @section }
      else
        format.html { render action: "new" }
        format.json { render json: @section.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sections/1
  # PUT /sections/1.json
  def update
    @section = Section.find(params[:id])
    Section.save_tax_classes(@section, params[:tax_classes]) if params[:tax_classes].present?

    respond_to do |format|
      if @section.update_attributes(params[:section])
        format.html { redirect_to sections_path, notice: 'Section was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @section.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sections/1
  # DELETE /sections/1.json
  def destroy
    @section = Section.find(params[:id])
    @section.destroy

    respond_to do |format|
      format.html { redirect_to sections_url }
      format.json { head :no_content }
    end
  end

  def delete_thirdparty_configuration
    @thirdparty_configuration = ThirdpartyConfiguration.find(params[:thirdparty_configuration_id])
    @thirdparty_configuration.destroy
    
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def set_module_details
    @module_id = "sections"
    @module_title = "Sections"
  end  
end
