class AppConfigurationsController < ApplicationController
  load_and_authorize_resource :except => [:save_config] #CanCan Authentication
  layout "material"

  before_filter :set_module_details

  # GET /app_configurations
  # GET /app_configurations.json
  def index
    @app_configurations = AppConfiguration.all
    # url = "http://services.groupkt.com/state/search/IND?text="
    # states_json = RestClient::Request.execute(method: :get, url: url)
    # @states = JSON.parse (states_json)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @app_configurations }
    end
  end

  # GET /app_configurations/1
  # GET /app_configurations/1.json
  def show
    @app_configuration = AppConfiguration.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @app_configuration }
    end
  end

  # GET /app_configurations/new
  # GET /app_configurations/new.json
  def new
    @app_configuration = AppConfiguration.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @app_configuration }
    end
  end

  # GET /app_configurations/1/edit
  def edit
    @app_configuration = AppConfiguration.find(params[:id])
  end

  # POST /app_configurations
  # POST /app_configurations.json
  def create
    @app_configuration = AppConfiguration.new(params[:app_configuration])
    respond_to do |format|
      if @app_configuration.save
        format.html { redirect_to @app_configuration, notice: 'App configuration was successfully added.' }
        format.js { render nothing: true }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.js { render nothing: true }
        format.json { render json: @app_configuration.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /app_configurations/1
  # PUT /app_configurations/1.json
  def update
    @app_configuration = AppConfiguration.find(params[:id])

    respond_to do |format|
      if @app_configuration.update_attributes(params[:app_configuration])
        format.html { redirect_to @app_configuration, notice: 'App configuration was successfully updated.' }
        format.js { render nothing: true }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.js { render nothing: true }
        format.json { render json: @app_configuration.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /app_configurations/1
  # DELETE /app_configurations/1.json
  def destroy
    @app_configuration = AppConfiguration.find(params[:id])
    @app_configuration.destroy

    respond_to do |format|
      format.html { redirect_to app_configurations_url }
      format.json { head :no_content }
    end
  end

  def basic_configurations
    AppConfiguration.load_basic_configurations()

    respond_to do |format|
      format.html { redirect_to app_configurations_path, notice: 'Basic app configuration was successfully loaded.' }
      format.json { head :no_content }
    end
  end

  def printers
    @printers = Printer.all
    @printer = Printer.new
  end

  def save_config
    @app_config = AppConfiguration.set_key(params[:config_key])
    if @app_config.present?
      @app_config.first.update_attribute(:config_value,params[:config_value])
    else
      @app_config = AppConfiguration.create(:config_key=> params[:config_key],:config_value=> params[:config_value])
    end
    respond_to do |format|
      format.json { render json: @app_config }
    end
  end

  def update_account
    begin
      @account = Account.find_by_subdomain(request.subdomain)
      @account.update_attribute(params[:column_name], params[:column_value])
      respond_to do |format|
        format.json { render json: @account.reload }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      respond_to do |format|
        format.json { render json: {:error=> e.message.to_s}, status: :unprocessable_entity }
      end
    end
  end
  def check_app_config
    config_status = AppConfiguration.get_config(params[:config_key])
    respond_to do |format|
      format.json { render json: {status:config_status} }
    end
  end
  private

  def set_module_details
    @module_id = "app_config"
    @module_title = "Application Configurations"
  end
end
