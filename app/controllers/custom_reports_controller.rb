class CustomReportsController < ApplicationController
  layout "material"
  
  before_filter :set_module_details  
  # GET /custom_reports
  # GET /custom_reports.json
  def index
    @custom_reports = CustomReport.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @custom_reports }
    end
  end

  # GET /custom_reports/1
  # GET /custom_reports/1.json
  def show
    @custom_report = CustomReport.find(params[:id])
    connection = ActiveRecord::Base.connection
    @result = connection.exec_query(@custom_report.query)
    respond_to do |format|
      format.html # show.html.erb
      
    end
  end

  # GET /custom_reports/new
  # GET /custom_reports/new.json
  def new
    @report_folder = ReportFolder.find(params[:report_folder_id])
    @custom_report = CustomReport.new
  
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @custom_report }
    end
  end

  # GET /custom_reports/1/edit
  def edit
    @report_folder = ReportFolder.find(params[:report_folder_id])
    @custom_report = CustomReport.find(params[:id])
  end

  # POST /custom_reports
  # POST /custom_reports.json
  def create
    @report_folder = ReportFolder.find(params[:report_folder_id])
    @custom_report = @report_folder.custom_reports.build(params[:custom_report])

    respond_to do |format|
      if @custom_report.save
        format.html { redirect_to report_folders_path, notice: 'Custom Report template was successfully created.' }
        #format.json { render json: @report, status: :created, location: @report }
      else
        format.html { render action: "new" }
        #format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /custom_reports/1
  # PATCH/PUT /custom_reports/1.json
  def update
    @custom_report = CustomReport.find(params[:id])

    respond_to do |format|
      if @custom_report.update_attributes(custom_report_params)
        
        format.html { redirect_to report_folders_path, notice: 'Custom Report template was successfully updated.' }
        
      else
        format.html { render action: "edit" }
        format.json { render json: @custom_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /custom_reports/1
  # DELETE /custom_reports/1.json
  def destroy
    @custom_report = CustomReport.find(params[:id])
    @custom_report.destroy

    respond_to do |format|
      format.html { redirect_to custom_reports_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def custom_report_params
      params.require(:custom_report).permit(:name, :query, :report_folder)
    end

    def set_module_details
      @module_id = "reports"
      @module_title = "Reports"
    end     
end
