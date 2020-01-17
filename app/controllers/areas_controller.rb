class AreasController < ApplicationController
  before_filter :set_return_to_path
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  # GET /areas
  # GET /areas.json
  def index
    @areas = Area.by_unit_id(current_user.unit.id).order("id ASC")

    smart_listing_create :areas, @areas, :partial=>"areas/areas_smart_list",page_sizes:[5]
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @areas }
      format.js
    end
  end

  # GET /areas/1
  # GET /areas/1.json
  def show
    @area = Area.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @area }
    end
  end

  # GET /areas/new
  # GET /areas/new.json
  def new
    @roles = Role.all
    @area = Area.new
    @zones = Zone.not_allocated_in_area
    @zones = @zones.zone_name_like(params[:zone_name]) if params[:zone_name].present?
    smart_listing_create :zones, @zones, :partial=>"areas/zone_smart_list",page_sizes:[5]
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @area }
      format.js
    end
  end

  # GET /areas/1/edit
  def edit
    @roles = Role.all
    @area = Area.find(params[:id])
    @zones = Zone.where("area_id=? or area_id IS NULL",@area.id)
    @zones = @zones.zone_name_like(params[:zone_name]) if params[:zone_name].present?
    smart_listing_create :zones, @zones, :partial=>"areas/zone_smart_list",page_sizes:[5]
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @zone }
      format.js
    end
  end

  # POST /areas
  # POST /areas.json
  def create
    @area = Area.new(area_params)
    @area.user_id = params[:user_id]
    @area.unit_id = current_user.unit.id
    zone_ids = params[:hidden_item_ids].split(",")
    respond_to do |format|
      if @area.save & Zone.save_area_to_zone(@area.id,zone_ids)
        format.html { redirect_to session.delete(:return_to), notice: 'Area was successfully created.' }
        format.json { render json: @area, status: :created, location: @area }
      else
        format.html { render action: "new" }
        format.json { render json: @area.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /areas/1
  # PATCH/PUT /areas/1.json
  def update
    @area = Area.find(params[:id])
    _old_zones = Zone.where("area_id=?", @area.id).pluck(:id)
    _new_zones = params[:hidden_item_ids].split(",")
    Zone.update_zone_for_area(_old_zones,_new_zones,@area.id) unless _old_zones.to_set == _new_zones.to_set
    respond_to do |format|
      if @area.update_attributes(area_params) and @area.update_attribute(:user_id, params[:user_id])
        format.html { redirect_to session.delete(:return_to), notice: 'Area was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @area.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /areas/1
  # DELETE /areas/1.json
  def destroy
    @area = Area.find(params[:id])
    if @area.destroy
      zones = Zone.where("area_id=?",params[:id])
      zones.each do |zone|
        zone.update_attribute(:area_id,nil)
      end
    end
    respond_to do |format|
      format.html { redirect_to areas_url }
      format.json { head :no_content }
    end
  end

  def fetch_users
    arr_users=[]
    if params[:area_id] != ''
      usr = Area.find(params[:area_id])
      usr = usr.user.profile
      arr_users.push({"id"=>usr.id, "name"=>usr.firstname + ' ' + usr.lastname})
    end
    user_role_id = Role.find(params[:role])
    all_user_id = UsersRole.where("role_id=?", user_role_id).pluck(:user_id)
    fetch_user = User.by_user_id_in(all_user_id)
    fetch_user.each do |fu|
      new_user={}
      if is_assigned_to_zone_or_area(fu.id) == false
        new_user["id"]=fu.id
        new_user["name"]=fu.profile.firstname+" "+fu.profile.lastname
        arr_users.push(new_user)
      end
    end
    respond_to do |format|
      format.json { render :json => arr_users }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def area_params
      params.require(:area).permit(:descriptions, :name, :status,:user_id)
    end

    def set_return_to_path
      session[:return_to] = request.referer
    end
end
