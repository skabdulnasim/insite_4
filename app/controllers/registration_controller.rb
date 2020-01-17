class RegistrationController < Devise::RegistrationsController

  def new
    @user = User.new
    # @profile = Profile.new
    @account = Account.new
  end

  def create
    begin
      @subdomain = Subdomain.find_by_auth_key(params[:auth_key])
      raise I18n.t(:error_invalid_license_key) unless @subdomain.present?
      _account = Account.by_subdomain(@subdomain.schema_name)
      raise I18n.t(:error_invalid_license_key) if _account.present?
      ActiveRecord::Base.transaction do
        # Setup account and schema for subdomain
        _account = Account.create(account_params)
        Apartment::Database.create(_account.subdomain)
        Apartment::Database.switch(_account.subdomain)
        # Adding config values
        AppConfiguration.register_subdomain_with_modules(@subdomain)
        # Adding default unittype and unit
        _unit_type = Unittype.create(unittype_params)
        _unit = Unit.new(unit_params)
        _unit_type.units << _unit
        # Adding admin Role and user
        _admin_role = Role.create(:name => 'super_admin')
        _admin_user = User.new(:email => 'admin@yottolabs.com', :password => 'welcome@123', :unit_id => _unit.id, :profile_attributes => {:full_name => 'Yottolabs Admin', :contact_no => '8336910662', :appurl => 'http://digitalbricks.co'})
        _admin_role.users << _admin_user
        # Adding new user and role
        _new_role = Role.create(:name => 'owner')
        _user = User.new(params[:user])
        _user.unit_id = _unit.id
        _new_role.users << _user
      end
      redirect_to onboarding_index_url(subdomain: _account.subdomain)
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to new_user_registration_path, alert: e.message
    end
  end

  private

  def account_params
    {
      "subdomain" => @subdomain.schema_name,
      "timezone" => params[:account][:timezone]
    }
  end

  def unittype_params
    {
      "unit_type_name"      => "owner",
      "unit_type_priority"  => 1,
      "store_creatability"  => 1
    }
  end

  def unit_params
    {
      "unit_name"   => "Default"
      #"latitude"    => request.location.latitude
      #"longitude"   => request.location.longitude
    }
  end

end
