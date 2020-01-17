class DeveloperAppsController < ApplicationController
  load_and_authorize_resource
  
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  before_filter :set_module_details 

  # GET /developer_apps
  # GET /developer_apps.json
  def index
    app_scope = DeveloperApp.order("updated_at desc")
    app_scope = app_scope.filter_by_string(params[:filter]) if params[:filter]    
    smart_listing_create :developer_apps, app_scope, partial: "developer_apps/apps_smartlist"

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @developer_apps }
    end
  end

  # GET /developer_apps/1
  # GET /developer_apps/1.json
  def show
    @developer_app = DeveloperApp.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @developer_app }
    end
  end

  # GET /developer_apps/new
  # GET /developer_apps/new.json
  def new
    @developer_app = DeveloperApp.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @developer_app }
    end
  end

  # GET /developer_apps/1/edit
  def edit
    @developer_app = DeveloperApp.find(params[:id])
  end

  # POST /developer_apps
  # POST /developer_apps.json
  def create
    @developer_app = DeveloperApp.new(developer_app_params)

    respond_to do |format|
      if @developer_app.save
        format.html { redirect_to @developer_app, notice: 'Developer app was successfully created.' }
        format.json { render json: @developer_app, status: :created, location: @developer_app }
      else
        format.html { render action: "new" }
        format.json { render json: @developer_app.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /developer_apps/1
  # PATCH/PUT /developer_apps/1.json
  def update
    @developer_app = DeveloperApp.find(params[:id])

    respond_to do |format|
      if @developer_app.update_attributes(developer_app_params)
        format.html { redirect_to @developer_app, notice: 'Developer app was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @developer_app.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /developer_apps/1
  # DELETE /developer_apps/1.json
  def destroy
    @developer_app = DeveloperApp.find(params[:id])
    @developer_app.destroy

    respond_to do |format|
      format.html { redirect_to developer_apps_url }
      format.json { head :no_content }
    end
  end

  private
    
    def set_module_details
      @module_id = "dev_apps"
      @module_title = "Developer Apps"
    end

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def developer_app_params
      params.require(:developer_app).permit(:app_secret, :description, :is_active, :name, :website)
    end
end
