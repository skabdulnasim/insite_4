class ReportFoldersController < ApplicationController
  layout "material"
  
  before_filter :set_module_details
  # GET /report_folders
  # GET /report_folders.json
  def index
    @report_folders = ReportFolder.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @report_folders }
    end
  end

  # GET /report_folders/1
  # GET /report_folders/1.json
  def show
    @report_folder = ReportFolder.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @report_folder }
    end
  end

  # GET /report_folders/new
  # GET /report_folders/new.json
  def new
    @report_folder = ReportFolder.new
    @report_folders = ReportFolder.all
    @master_models = ReportFolder.master_models
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @report_folder }
    end
  end

  # GET /report_folders/1/edit
  def edit
    @report_folder = ReportFolder.find(params[:id])
  end

  # POST /report_folders
  # POST /report_folders.json
  def create
    @report_folder = ReportFolder.new(params[:report_folder])
    respond_to do |format|
      if @report_folder.save
        format.html { redirect_to attributes_accessible_path(@report_folder), notice: 'Report folder was successfully created.' }
        format.json { render json: @report_folder, status: :created, location: @report_folder }
      else
        format.html { render action: "new" }
        format.json { render json: @report_folder.errors, status: :unprocessable_entity }
      end
    end
  end
  def attributes_accessible
    @report_folder = ReportFolder.find(params[:id])
    @data_tables = Report.get_model_info(params[:id])
    if params[:attributes_accessible]
      
      @report_folder.attributes_accessible = params[:attributes_accessible].join(',')
      respond_to do |format|
        if @report_folder.save
          format.html { redirect_to report_folders_path, notice: 'Report folder Accessible Attributes Successfully Created.' }
          format.json { render json: @report_folder, status: :created, location: @report_folder }
        else
          format.html { render action: "new" }
          format.json { render json: @report_folder.errors, status: :unprocessable_entity }
        end
      end
   end
  end

  # PUT /report_folders/1
  # PUT /report_folders/1.json
  def update
    @report_folder = ReportFolder.find(params[:id])

    respond_to do |format|
      if @report_folder.update_attributes(params[:report_folder])
        format.html { redirect_to @report_folder, notice: 'Report folder was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @report_folder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /report_folders/1
  # DELETE /report_folders/1.json
  def destroy
    @report_folder = ReportFolder.find(params[:id])
    @report_folder.destroy

    respond_to do |format|
      format.html { redirect_to report_folders_url }
      format.json { head :no_content }
    end
  end

  def select_relation
    if(params[:master_model])
      @relation_models = ReportFolder.relational_models(params[:master_model])
    else
      @relational_models = []
    end
    render layout: false
  end

  private
  
  def set_module_details
    @module_id = "reports"
    @module_title = "Reports"
  end  
end
