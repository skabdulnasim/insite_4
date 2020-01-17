class ReportsController < ApplicationController
  layout "material"
  
  before_filter :set_module_details  
  # GET /reports/1
  # GET /reports/1.json
  def show
    @report = Report.find(params[:id])
    @account = request.subdomain
    @report_data = @report.generate_report
    @report_agg_data = @report.aggregation_attributes if @report.aggregation_functions.present?
  
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @report }
      format.pdf { render :layout => false } # Add this line
    end
  end

  # GET /reports/new
  # GET /reports/new.json
  def new
    @report_folder = ReportFolder.find(params[:report_folder_id]);
    @report = Report.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @report }
    end
  end

  # POST /reports
  # POST /reports.json
  def create
    @report_folder = ReportFolder.find(params[:report_folder_id])
    @report = @report_folder.reports.build(params[:report])

    respond_to do |format|
      if @report.save
        format.html { redirect_to customize_step_report_folder_report_path(@report_folder,@report,1), notice: 'Report template was successfully created.' }
        #format.json { render json: @report, status: :created, location: @report }
      else
        format.html { render action: "new" }
        #format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /reports/1/edit
  def customize
    
    @form_data = params
    @data_tables = Report.get_model_info(params[:report_folder_id])
    @report_folder = ReportFolder.find(params[:report_folder_id])
    @report = Report.find(params[:id])
    if request.get? || params[:step_id]=='1'
      @partial_view  = "model_listing"
    end
    if request.post?
      if params[:step_id]=='2' 
        @partial_view = 'criteria'
      elsif params[:step_id]=='3'
        @partial_view = 'extra_criteria'
        @report.report_selectors = params[:report_selectors].join(",")
        @report.report_criteria = params[:report][:report_criteria]
        @report.save
      elsif params[:step_id]=='4'
        @form_data[:report_selectors] = @report.report_selectors.split(',')
        @partial_view = 'final'
        if params[:report] && params[:report][:aggregation_functions]
          @report.aggregation_functions = params[:report][:aggregation_functions].join(",")
          @report.save
        end
      elsif params[:step_id]=='5'
        @report.group_attribute = ''
        @report.order_attribute = ''
        if params[:report] && params[:report][:group_attribute]
          @report.group_attribute = params[:report][:group_attribute] 
        end
        if params[:report] && params[:report][:order_attribute]
          @report.order_attribute = params[:report][:order_attribute] 
        end
        respond_to do |format|
          if @report.save
            format.html { redirect_to report_folders_path, notice: 'Report was successfully created.' }
          end
        end
      else
        redirect_to customize_step_report_folder_report_path(@report_folder,@report,1)
      end
    end
  end

  def destroy
    @report = Report.find(params[:id])
    @report.destroy
    respond_to do |format|
      format.html { redirect_to reports_url, notice: 'Report successfully Deleted.' }
      format.json { head :no_content }
    end
  end
 
  def get_bill_wise_report
    if params[:device_id].present?
      @array = Report.bill_wise_report(params)
    end
    rescue Exception => @error
  end

  def get_category_wise_report
    @unit = Unit.find(params[:unit_id])
    @unit_detail_options = @unit.unit_detail.options
    if params[:from_date].present?
      _from_datetime = params[:from_date].to_date.beginning_of_day+@unit_detail_options[:day_closing_time].to_i.hours
      _from_datetime ||= params[:from_date].to_date.beginning_of_day
      _to_datetime = params[:to_date].to_date.end_of_day+@unit_detail_options[:day_closing_time].to_i.hours
      _to_datetime ||= params[:to_date].to_date.end_of_day
    else
      _from_datetime = params[:date].to_date.beginning_of_day+@unit_detail_options[:day_closing_time].to_i.hours
      _from_datetime ||= params[:date].to_date.beginning_of_day
      _to_datetime = params[:date].to_date.end_of_day+@unit_detail_options[:day_closing_time].to_i.hours
      _to_datetime ||= params[:date].to_date.end_of_day
    end
    if params[:device_id].present? && params[:unit_id].present?
      @category_sales = Report.category_wise_report(params)
      @settlement_data = Bill.get_unit_settlement_data(params[:unit_id],_from_datetime,_to_datetime)
    end
    rescue Exception => @error
  end

  private

  def set_module_details
    @module_id = "reports"
    @module_title = "Reports"
  end    
end
