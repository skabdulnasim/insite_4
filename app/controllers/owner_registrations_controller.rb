class OwnerRegistrationsController < ApplicationController
  # GET /owner_registrations
  # GET /owner_registrations.json
  #load_and_authorize_resource :except => [:fetch_unit_from_unittype]
  def index
    @owner_registrations = OwnerRegistration.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @owner_registrations }
    end
  end

  # GET /owner_registrations/1
  # GET /owner_registrations/1.json
  def show
    @owner_registration = OwnerRegistration.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @owner_registration }
    end
  end

  # GET /owner_registrations/new
  # GET /owner_registrations/new.json
  def new
    @owner_registration = OwnerRegistration.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @owner_registration }
    end
  end
  
  # GET /owner_registrations/1/edit
  def edit
    @owner_registration = OwnerRegistration.find(params[:id])
  end
    
  # POST /owner_registrations
  # POST /owner_registrations.json
  def create
    @owner_registration = OwnerRegistration.new(params[:owner_registration])
    directory_name = Rails.root.join('public', 'uploads', 'resturants')
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    if params[:owner_registration][:resturant_image]
      uploaded_io = params[:owner_registration][:resturant_image]
      File.open(Rails.root.join('public', 'uploads', 'resturants', uploaded_io.original_filename), 'wb') do |file|
        file.write(uploaded_io.read)
      end
      @owner_registration[:resturant_image] = uploaded_io.original_filename
    end
    
    respond_to do |format|
      if @owner_registration.save
        format.html { redirect_to @owner_registration, notice: 'Owner registration was successfully created.' }
        format.json { render json: @owner_registration, status: :created, location: @owner_registration }
      else
        format.html { render action: "new" }
        format.json { render json: @owner_registration.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /owner_registrations/1
  # PUT /owner_registrations/1.json
  def update
    @owner_registration = OwnerRegistration.find(params[:id])
    
    directory_name = Rails.root.join('public', 'uploads', 'resturants')
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    if params[:owner_registration][:resturant_image]
      uploaded_io = params[:owner_registration][:resturant_image]
      params[:owner_registration][:resturant_image] = uploaded_io.original_filename
      File.open(Rails.root.join('public', 'uploads', 'resturants', uploaded_io.original_filename), 'wb') do |file|
        file.write(uploaded_io.read)
      end
      #@owner_registration[:resturant_image] = uploaded_io.original_filename
    end

    respond_to do |format|
      if @owner_registration.update_attributes(params[:owner_registration])
        format.html { redirect_to @owner_registration, notice: 'Owner registration was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @owner_registration.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /owner_registrations/1
  # DELETE /owner_registrations/1.json
  def destroy
    @owner_registration = OwnerRegistration.find(params[:id])
    @owner_registration.destroy

    respond_to do |format|
      format.html { redirect_to owner_registrations_url }
      format.json { head :no_content }
    end
  end
  
  
  #fetch unit parent dropdown while creating a unit depending on the value of the unit type that we will create
  def fetch_unit_from_unittype
    @id = params[:id]
    #@search_id = @id -'1';
    @type_prio = Unittype.where(:id => @id)
    @type_prio_id = @type_prio[0].unit_type_priority
    #@Req_type_prio = Unittype.where("unit_type_priority <?", @type_prio_id)
    # @Req_type_prio = Unittype.find(:all, :select => 'id', :conditions => ["unit_type_priority =?", @type_prio_id])
    @Req_type_prio = Unittype.where(:unit_type_priority => @type_prio_id).select(:id)
    ids = Array.new 
    @Req_type_prio.each do |r|
     ids.push(r.id)
    end
    @type_info = Unit.where(:unittype_id => ids)
    respond_to do |format|
      format.json { render :json => @type_info}
      end
    end
  
  def new_staff
    @user = User.new
    @profile = Profile.new
    @unittypes = Unittype.all
    #@groups = Group.all
    @roles = Role.all
    @current_user_id = get_current_user_id()
    @current_user_info = UserManagement::get_current_user(@current_user_id)
    @owner_registrations = OwnerRegistration.all[0]
    if @current_user_info.unit_id
      @users = User.where(:unit_id => @current_user_info.unit_id)
    else
      @users = User.all
    end
  end
  
  def edit_staff
    @user = User.find(params[:id])
    @profile = Profile.where(:user_id => @user.id).first
  end
  
  def staff_update
    @profile = Profile.find(params[:id])
    
    respond_to do |format|
      if Profile.where(:id => params[:id]).update_all(:firstname =>params[:profile][:firstname], :lastname =>params[:profile][:lastname], :contact_no=>params[:profile][:contact_no], :appurl=>params[:profile][:appurl], :address=>params[:profile][:address], :city=>params[:profile][:city], :state=>params[:profile][:state], :zip_code=>params[:profile][:zip_code], :country=>params[:profile][:country])
        format.html { redirect_to owner_registrations_profile_path, notice: 'Your profile has been successfully updated.' }
      end      
    end 
  end
  
  def staff_create
    @user = User.new(params[:user])
    @profile = Profile.new(params[:profile])

    if @user.valid? && @user.errors.blank?
      @user.save
      @profile.user = @user
      @profile.save
      
      @user_role = UsersRole.new
      @user_role[:user_id] = @user.id
      @user_role[:role_id] = params[:role_id]
      @user_role.save
      
      respond_to do |format|
        format.html { redirect_to owner_registrations_new_staff_path, notice: 'Your profile has been successfully created.' }
      end 
    else
      respond_to do |format|
        format.html { render :action => "new_staff", notice: 'Your profile has been successfully created.' }
      end 
    end 
  end
  
  def change_password
    @user = User.find(params[:id])
  end
  
  def update_password
    @user = User.find(params[:id])
    check = @user.valid_password?(params[:cur_pwd])
    if check == true
      if params[:user][:password] == params[:user][:password_confirmation]
        respond_to do |format|
          if @user.save
            format.html { redirect_to owner_registrations_profile_path, notice: 'Your profile has been successfully updated.' }
          end      
        end 
      else
        respond_to do |format|
          format.html { redirect_to owner_registrations_change_password_path+"?id="+params[:id], notice: 'Your have re-entered a wrong password.' }
        end         
      end
    else
      respond_to do |format|
        format.html { redirect_to owner_registrations_change_password_path+"?id="+params[:id], notice: 'Your have entered wrong password.' }
      end      
    end
    
  end
  
  

  private
  def check_user_in_cas(email)
    _member = Member.where(:email => email).first
    return _member
  end

  # GET /owner_registrations/all_roles.json
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  api :GET, '/owner_registrations/all_roles.json', "Get all roles for current units."
  error :code => 401, :desc => "Unauthorized"
  description "URL : http://lazeez.stewot.com/owner_registrations/all_roles.json?device_id=YOTTO05" 
  formats ['json', 'html']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def all_roles
    _roles = Role.all  
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: _roles }
    end
  end
  

end
