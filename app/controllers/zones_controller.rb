class ZonesController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  def index
    @zones = Zone.by_unit_id(current_user.unit.id).order("id ASC")
    smart_listing_create :zones, @zones, partial:"zones/zones_smart_list"
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @zones }
      format.js
    end
  end

  # GET /zones/1
  # GET /zones/1.json
  def show
    @zone = Zone.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @zone }
    end
  end

  # GET /zones/new
  # GET /zones/new.json
  def new
    session[:return_to] = request.referer
    @roles = Role.all
    @zone = Zone.new
    @bits = Bit.not_allocated_in_zone
    @bits =  @bits.bit_name_like(params[:bit_name]) if params[:bit_name].present?
    smart_listing_create :bits, @bits, :partial=>"zones/bit_smart_list",page_sizes:[5] 
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @zone }
      format.js
    end
  end

  # GET /zones/1/edit
  def edit
    @roles = Role.all
    session[:return_to] = request.referer
    @zone = Zone.find(params[:id])
    @bits = Bit.where("zone_id=? OR zone_id IS NULL", @zone.id)
    @bits =  @bits.bit_name_like(params[:bit_name]) if params[:bit_name].present?
    smart_listing_create :bits,@bits, :partial=>"zones/bit_smart_list",page_sizes:[5]
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @zone }
      format.js
    end
  end

  # POST /zones
  # POST /zones.json
  def create
    puts params
    @zone = Zone.new(zone_params)
    @zone.user_id = params[:user_id]
    @zone.unit_id = current_user.unit.id
    bit_ids = params[:hidden_item_ids].split(",")
    respond_to do |format|
      if @zone.save & Bit.save_bit_to_zone(@zone.id,bit_ids)
        format.html { redirect_to session.delete(:return_to), notice: 'Zone was successfully created.' }
        format.json { render json: @zone, status: :created, location: @zone }
      else
        format.html { render action: "new" }
        format.json { render json: @zone.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /zones/1
  # PATCH/PUT /zones/1.json
  def update
    @zone = Zone.find(params[:id])
    _old_bits = Bit.where("zone_id=?",@zone.id).pluck(:id)
    _new_bits = params[:hidden_item_ids].split(",")
    Bit.update_bit_for_zone(_old_bits,_new_bits,@zone.id) unless  _old_bits.to_set == _new_bits.to_set
    respond_to do |format|
      if @zone.update_attributes(zone_params) and @zone.update_attribute(:user_id, params[:user_id])
        format.html { redirect_to session.delete(:return_to), notice: 'Zone was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @zone.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /zones/1
  # DELETE /zones/1.json
  def destroy
    puts params[:id]
    @zone = Zone.find(params[:id])
    if @zone.destroy
      bits = Bit.where("zone_id=?",params[:id])
      bits.each do |bit|
        bit.update_attribute(:zone_id,nil)
      end
    end
    respond_to do |format|
      format.html { redirect_to request.referer, notice: 'Zone was successfully removed' }
      format.json { head :no_content }
    end
  end

  def fetch_users
    arr_users=[]
    
    if params[:zone_id]!=''
      usr = Zone.find(params[:zone_id])
      usr = usr.user.profile
      arr_users.push({"id"=>usr.user_id,"name"=>usr.firstname+" "+ usr.lastname})
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
    def zone_params
      params.require(:zone).permit(:descriptions, :name, :status)
    end
end
