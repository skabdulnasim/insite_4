class ApplicationController < ActionController::Base

  require 'session_management'
  include SessionManagement
  include ApplicationHelper

  protect_from_forgery

  # layout :layout_by_resource

  before_filter :custom_authentication
  before_filter :load_schema
  before_filter :set_time_zone

  def get_current_user
    @current_user = current_user
  end

private

  # Loading schema based on subdomain
  def load_schema
    Apartment::Tenant.switch!('public')
    return unless request.subdomain.present?
    Apartment::Tenant.switch!(request.subdomain)
  end

  # Custom authentication for both users and devices
  def custom_authentication
    if params.has_key?("device_id")
      if params[:device_id]!= "YOTTO05"
        _subdomain_id_key = AppConfiguration.where(:config_key => 'site_id').first
        _device = DmInit.set_id(params[:device_id].to_i).set_subdomain(_subdomain_id_key.config_value.to_i).active_device.first
        if !_device.present?
          render :json => {:status =>"error.", :messages => {:simple_message=> "Device authentication failed.", :internal_message=> "Authentication failed."}, :data=>{}}, :status => 401
        end
      end
    else
      check_user_status
      authenticate_user!
    end
  end

  # Token authentication
  def authenticate_user_with_token!
    case request.format
    when Mime::JSON
      user_email = params[:email] || request.headers['X-USER-EMAIL']
      user       = user_email && User.find_by_email(user_email)

      # Notice how we use Devise.secure_compare to compare the token in the
      # database with the token given in the params, mitigating timing attacks.
      if user && request.headers['Authorization'] && Devise.secure_compare(user.auth_token, request.headers['Authorization'])
        sign_in user, store: false
        @current_user = user
      elsif current_user.present?
        @current_user = current_user
      elsif user && request.headers['X-APP-ID'] && DeveloperApp.authenticate(request.headers['X-APP-ID'], request.headers['X-APP-SECRET'])
        sign_in user, store: false
        @current_user = user
      else
        render :json => {:status =>"error.", :messages => {:simple_message=> "API authentication failed.", :internal_message=> "Authentication failed."}, :data=>{}}, :status => 401
      end
    end
  end

  # Fetching controller namespace
  def namespace
    controller_name_segments = params[:controller].split('/')
    controller_name_segments.pop
    controller_namespace = controller_name_segments.join('/').camelize
  end

  #derive the model name from the controller. egs UsersController will return User
  def self.permission
    return name = self.name.gsub('Controller','').singularize.split('::').last.constantize.name rescue nil
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, namespace)
  end

  #load the permissions for the current user so that UI can be manipulated
  def load_permissions
    @current_permissions = current_user.role.permissions.collect{|i| [i.subject_class, i.action]}
  end

  # Cancan exception handling
  rescue_from CanCan::AccessDenied do |exception|
    root_url = get_root_url             
    Rscratch::Exception.log exception,request
    respond_to do |format|
      format.html { redirect_to root_url, :notice => exception.message}
      format.json {render json: {:status =>"error", :messages => {:simple_message=> "Forbidden.", :internal_message=> exception.message}, :data=>{}}, :status => 403}
    end
  end

  # Verifying user
  def verify_user
    if current_user
      _user = User.where(:email => current_user.email).first
      if _user.nil?
        sign_out _user
      end
    end
  end

  # Verifying user status
  def check_user_status
    if current_user
      if current_user.status == 0
        sign_out current_user
      end
    end
  end

  def error_messages_for(*objects)
    error_string = ""
    objects = objects.map {|o| o.is_a?(String) ? instance_variable_get("@#{o}") : o}.compact
    errors = objects.map {|o| o.errors.full_messages}.flatten
    error_string = errors.map { |e|  "#{e}" }.join(', ') if errors.any?
  end

  def set_timerange
    _unit = Unit.find(params[:unit_id]) if params[:unit_id].present?
    unit_detail_options = _unit.unit_detail.options if _unit.present? && _unit.unit_detail.present?
    unit_detail_options ||= current_user.unit.unit_detail.options if current_user.present? && current_user.unit.unit_detail.present?

    _closing_hour = unit_detail_options.present? ? unit_detail_options[:day_closing_time].to_i : (0).to_i
    _closing_time = _closing_hour.hours

    if params[:from_date].present? && params[:from_date].to_date < "2016-04-01".to_date
      params[:from_date] = "2016-04-01"
    end
    if params[:from_date].present? && params[:to_date].present?
      @from_datetime = params[:from_date].to_date.beginning_of_day+_closing_time
      @to_datetime = params[:to_date].to_date.end_of_day+_closing_time
    elsif params[:from_date].present?
      @from_datetime = params[:from_date].to_date.beginning_of_day+_closing_time
      @to_datetime = @from_datetime.end_of_day+_closing_time
    elsif params[:delivery_date].present?
      @from_datetime = params[:delivery_date]
    else
      @from_datetime = Date.today.beginning_of_day+_closing_time
      @to_datetime = Date.today.end_of_day+_closing_time
    end
    _current_hour = Time.current.hour
    _today = _current_hour < _closing_hour ? Date.current.prev_day : Date.current

    @today_from_datetime  =  _today.beginning_of_day.utc+_closing_time
    @today_to_datetime    =  _today.end_of_day.utc+_closing_time
  end

  # Setting timezone of current user
  def set_time_zone()
    zone = current_user.unit.time_zone if current_user.present?
    account = Account.find_by_subdomain(request.subdomain)
    zone ||= account.timezone if account.present?
    zone ||= 'UTC'
    Time.zone = zone
  end
end
