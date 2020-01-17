class UsersController < ApplicationController
  load_and_authorize_resource :except => [:fetch_address_details]

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  
  layout "material"

  before_filter :set_module_details

  # GET /users
  # GET /users.json
  def index
    # puts current_user.inspect
    # child_user_list = nested_child_users(current_user,[])
    # child_user_list.each do |child_user|
    #   puts child_user.users_role.role.name
    # end
    # @users = User.find(:all) rails 4 comment
    @users = User.all
    user_scope = User.where('email <>(?)', "")
    user_scope = user_scope.filter_by_unit(params[:unit_id]) if params[:unit_id].present?
    user_scope = user_scope.filter_by_user_status(params[:status]) if params[:status].present?
    #user_scope = user_scope.filter_by_role(params[:role_id]) if params[:role_id].present?
    user_scope = user_scope.filter_by_string(params[:filter_user]) if params[:filter_user].present?
    smart_listing_create :users, user_scope, partial: "users/users_smartlist", default_sort: {id: "desc"}

    respond_to do |format|
      format.js # index.js.erb
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def get_users
    @current_user = current_user
    @user_hash={}
    @user_hash["id"]=@current_user.id
    @user_hash["email"]=@current_user.email
    @user_hash["firstname"]=@current_user.profile.firstname
    @user_hash["lastname"]=@current_user.profile.lastname
    @user_hash["unit_id"]=@current_user.unit_id
    @user_hash["children"]=[]
    @current_user_children = User.user_children(@current_user.id)
    if User.has_child(@current_user.id)
      @current_user_children.each do |chld|
        @children_hash={}
        @children_hash["id"]=chld.id
        @children_hash["email"]=chld.email
        @children_hash["firstname"]=chld.profile.firstname
        @children_hash["lastname"]=chld.profile.lastname
        @children_hash["unit_id"]=chld.unit_id
        @user_hash["children"].push(@children_hash)
      end
    end
    respond_to do |format|
      format.json { render json: @user_hash }
    end 
  end 

  # GET /users/1
  # GET /users/1.json
  def profile
    @user = User.find(params[:id])
    @profile = @user.profile

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new  
    @user = User.new
    @unittypes = Unittype.all
    
    @roles = Role.set_role_in(nested_child_roles(current_user.role.id))

  end
  
  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    puts "user to update #{@user.inspect}"
    @profile = @user.profile
    # case current_user.role.name
    #   when "owner"
    #     @roles = Role.all
    #   when "dc_manager"
    #     @roles_names=Array ['owner']
    #     @roles = Role.not_in_role_names(@roles_names)
    #   when "outlet_manager"
    #     @roles_names=Array ['owner','dc_manager','outlet_manager']
    #     @roles = Role.not_in_role_names(@roles_names)
    #   when "bill_manager"
    #     @roles_names=Array ['sale_person']
    #     @roles = Role.filter_by_role_names(@roles_names)
    # end
    @roles = Role.set_role_in(nested_child_roles(current_user.role.id))
    puts params
    # parent_role=""
    # case @user.role.name
    #   when "owner"
    #     parent_role=""
    #     @parent_info =User.by_role_name(parent_role)
    #   when "dc_manager"
    #     parent_role="owner"
    #     @parent_info =User.by_role_name(parent_role)
    #   when "outlet_manager"
    #     parent_role="dc_manager"
    #     @parent_info =User.by_role_name(parent_role)
    #   when "bill_manager"
    #     parent_role="outlet_manager"
    #     @parent_info =User.by_unit(current_user.unit_id).by_role_name(parent_role)
    #   when "mall_client"
    #     parent_role="outlet_manager"
    #     @parent_info =User.by_unit(current_user.unit_id).by_role_name(parent_role)
    #   when "sale_person"
    #     parent_role="bill_manager"
    #     @parent_info =User.by_unit(current_user.unit_id).by_role_name(parent_role)
    #   else
    #     parent_role="outlet_manager"
    #     @parent_info =User.by_unit(current_user.unit_id).by_role_name(parent_role)
    # end
    _user = User.find(params[:id])

    @parent_info = User.by_unit(_user.unit_id).by_role_name(_user.role.parent_role.name) if _user.role.parent_role.present?
    # @parent_info = User.by_unit(current_user.unit_id).by_role_name(current_user.role.parent_role.name)

    # @parent_info =User.by_unit(current_user.unit_id).by_role_name(parent_role)
    # @parent_info =User.by_role_name(parent_role)
  end

  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, notice: 'User was successfully created.' }
        format.js
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def create_user
    @user = User.new(params[:user])
    @user['key_phrase'] = rand(10000)
    @profile = @user.build_profile(params[:profile])
    respond_to do |format|
      if @user.save && User.save_user_role(@user.id, params[:role_id])
        #Register user in CAS
        register_user_in_cas(params[:user][:email],params[:user][:password])
        format.js
        format.html { redirect_to users_path, notice: 'User was successfully created.' }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def import
    begin
      ActiveRecord::Base.transaction do
        User.import(params[:file])
        redirect_to :back, notice: 'Users was successfully imported.'
      end      
    rescue Exception => e
      flash[:error] = e.message
      redirect_to :back
    end
  end
  
  
  # PUT /users/1
  # PUT /users/1.json
  def update
    puts "params from edit form :  #{params}"
    @user = User.find(params[:id])
    respond_to do |format|

      @user.update_attributes(params[:user])
      if !params[:profile] and params[:user]
        @profile = @user.profile
        if @user.update_attributes(params[:user])
          format.html { redirect_to users_path, notice: 'Your account has been successfully updated.' }          
        else
          format.html { render action: "edit" }
          format.json { render json: @user.errors, notice: 'failed to update.' }
        end
      end

      if params[:profile]
        @profile = @user.profile
        if Profile.where(:user_id => params[:id]).update_all(:firstname =>params[:profile][:firstname], :lastname =>params[:profile][:lastname], :contact_no=>params[:profile][:contact_no], :address=>params[:profile][:address], :city=>params[:profile][:city], :state=>params[:profile][:state], :zip_code=>params[:profile][:zip_code], :country=>params[:profile][:country])
          format.html { redirect_to users_path, notice: 'Your profile has been successfully updated.' }          
        else
          format.html { render action: "edit" }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end
  end
  def delete_user
    @user = User.find(params[:id])
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def toggle_status
    _user = User.find(params[:id])
    _status =_user.status == 1 ? 0 : 1
    _user.update_attributes(:status => _status)
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User account successfully updated.' }
    end
  end

  def change_password
    @user = User.find(params[:id])
  end

  def update_password
    @user = User.find(params[:id])
    if @user.valid_password?(params[:cur_pwd])
      if params[:user][:password] == params[:user][:password_confirmation]
        respond_to do |format|
          if @user.update_attributes(params[:user])
            #Generate and update password
            pepper = nil
            cost = 10
            _encrypted_password = ::BCrypt::Password.create("#{params[:user][:password]}#{pepper}", :cost => cost).to_s            
            Member.where(:email => @user.email).update_all(:encrypted_password => _encrypted_password)
            format.html { redirect_to users_path, notice: 'Password has been successfully updated.' }
          end
        end
      else
        respond_to do |format|
          format.html { render action: "change_password", notice: "You have entered a wrong password." }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end 
      end
    else
      respond_to do |format|
        format.html { render action: "change_password", notice: "Your have re-entered a wrong password." }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end      
    end
  end

  def fetch_address_details
    @address = params[:address]
    @address_info = Geocoder.search(@address)
    @profile_data = {}
    @sublocality = Array.new
    @routes = Array.new
    @street_number = Array.new
    if @address_info
      @address_info.each do |ui|
        @addrs_comp = ui.address_components
        @addrs_comp.each do |ac|
          if ac["types"].include? "country"
            country = ac["long_name"]
            @profile_data[:country] = country
          end
          if ac["types"].include? "administrative_area_level_1"
            state = ac["long_name"]
            @profile_data[:state] = state
          end
          if ac["types"].include? "administrative_area_level_2"
            city = ac["long_name"]
            @profile_data[:district] = city
          end
          if ac["types"].include? "locality"
            locality = ac["long_name"]
            @profile_data[:city] = locality
          end
          if ac["types"].include? "sublocality"
            @sublocality.push ac["long_name"]
          end
          if ac["types"].include? "route"
            @routes.push ac["long_name"]
          end
          if ac["types"].include? "street_number"
            @street_number.push ac["long_name"]
          end
          if ac["types"].include? "postal_code"
            @profile_data[:pincode] = ac["long_name"]
          end
        end
        @profile_data[:locality] = @sublocality
        @profile_data[:route] = @routes
        @profile_data[:street_number] = @street_number
      end
    end
    respond_to do |format|
      format.json { render json: @profile_data }
    end
  end

#   def fetch_parent_users
#     parent_role=""
#     case params[:role]
#       when "owner"
#         parent_role=""
#       when "dc_manager"
#         parent_role="owner"
#       when "outlet_manager"
#         parent_role="dc_manager"
#       when "bill_manager"
#         parent_role="outlet_manager"
#       when "mall_client"
#         parent_role="outlet_manager"
#       when "sale_person"
#         parent_role="bill_manager"
#       when "sourcing_exec"
#         parent_role="bill_manager"  
#       else
#         parent_role="outlet_manager"
#     end

#     parent_info =ActiveRecord::Base.connection_pool.with_connection { |con| con.exec_query("SELECT users.id AS id, profiles.firstname AS firstname, profiles.lastname AS lastname,roles.id AS role_id FROM users 
# INNER JOIN profiles ON users.id=profiles.user_id
# INNER JOIN users_roles ON users.id=users_roles.user_id 
# INNER JOIN roles ON users_roles.role_id=roles.id AND roles.name='#{parent_role}'")}

#     respond_to do |format|
#       format.json { render :json => parent_info}
#     end
#   end

  def fetch_parent_users
    role_id = params[:role]
    puts "role_id: #{role_id}"
    parent_role_id = Role.find(role_id).parent
    puts "parent_role_id: #{parent_role_id}"

    parent_info =ActiveRecord::Base.connection_pool.with_connection { |con| con.exec_query("SELECT users.id AS id, profiles.firstname AS firstname, profiles.lastname AS lastname,users_roles.role_id AS role_id FROM users 
INNER JOIN profiles ON users.id=profiles.user_id
INNER JOIN users_roles ON users.id=users_roles.user_id AND users_roles.role_id='#{parent_role_id}'")}
    respond_to do |format|
      format.json { render :json => parent_info}
    end
  end

  def update_custom_sync
    @user = User.find(params[:user_id])
    @user.update_attribute(:custom_sync,params[:custom_sync_value])
    respond_to do |format|
      format.json { render json: @user }
    end
  end

  private
  
  def set_module_details
    @module_id = "users"
    @module_title = "Users"
    @child_role_ids = []
  end
  
  def register_user_in_cas(_email, _password)
    # _subdomain_id = AppConfiguration.find(:first, :conditions=>["config_key =?",'site_id']) rails 4 comment
    _subdomain_id = AppConfiguration.where("config_key =?",'site_id').first
    _subdomain = Subdomain.find((_subdomain_id.config_value).to_i)
    _cas_user = check_user_in_cas(_email)
    if _cas_user.blank?
      #generate site_url json
      _sites_arr = Array.new
      _arr = {}
      _arr[:site_url] = _subdomain.url
      _arr[:site_title] = _subdomain.name
      _sites_arr.push(_arr)
      _site_url_json = JSON.generate(_sites_arr)
      #Generate password
      pepper = nil
      cost = 10
      _encrypted_password = ::BCrypt::Password.create("#{_password}#{pepper}", :cost => cost).to_s
      _member = Member.new(:email => _email, :encrypted_password => _encrypted_password,:site_url => _site_url_json)
      _member.save
      _member.subdomains << _subdomain #Insert data in join table
    else
      _site_url_arr =JSON.parse(_cas_user.site_url)
      #generate site_url json
      _arr = {}
      _arr[:site_url] = _subdomain.url
      _arr[:site_title] = _subdomain.name
      _site_url_arr.push(_arr)
      _site_urls_json = JSON.generate(_site_url_arr)
      Member.where(:email => _cas_user.email).update_all(:site_url => _site_urls_json)
      _cas_user.subdomains << _subdomain #Insert data in join table
    end
  end

  # => Check if the user is present in CAS or not
  def check_user_in_cas(email)
    _member = Member.where("email=?",email).first
    return _member
  end

  def nested_child_roles(role_id)
    _child_role_ids = []
    _child_roles = Role.child_roles(role_id)
    if _child_roles.present?
      _child_roles.each do |cr|
        @child_role_ids.push cr.id
        nested_child_roles(cr)
      end
    end
    @child_role_ids
  end

end

