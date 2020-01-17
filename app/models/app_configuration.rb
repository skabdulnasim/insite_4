class AppConfiguration < ActiveRecord::Base
  attr_accessible :config_key, :config_value

  # => Model validations
  validates :config_key,         :presence => true
  validates :config_value,       :presence => true

  after_create :setup_organization_structure, if: :is_business_type_config?

  # => Model Scopes
  scope :set_key,   lambda {|key|where(["config_key=?", key])}
  scope :set_keys,   lambda {|keys|where(["config_key IN(?)", keys])}
  scope :tsp_configuration,  lambda { where("config_key IN ('tsp_module','tsp_get_resource_stock','accept_new_order','future_order','item_remarks','pedler_work_on_offline','live_tracking_and_timeline','resource_order_history','distribution_config','b2b_billing')")}

  def self.get_config_value(config_key)
    # conf = AppConfiguration.find(:first, :conditions => ['config_key =?', config_key]) #commented due to rails4 migration
    conf = AppConfiguration.where("config_key =?", config_key).first
    config_value = conf.present? ? conf.config_value : 'disabled'
  end

  def self.get_config_value_of_report(config_key)
    conf = AppConfiguration.find_by(config_key: config_key)
    config_value = conf.present? ? conf.config_value : 2
  end

  def self.get_config(config_key)
    conf = AppConfiguration.find_by(config_key: config_key)
    config_value = conf.present? ? conf.config_value : ''
  end

  def self.load_basic_configurations()
  	AppConfigurationManagement.load_basic_configurations("req_auto_adjust", 1)
  	AppConfigurationManagement.load_basic_configurations("purchase_order_auto_adjust", 1)
    AppConfigurationManagement.load_basic_configurations("owner_will_crud_menu", 1)
    AppConfigurationManagement.load_basic_configurations("low_over_stock_alert", 0)
  end

  def self.create_for key, value
    config = AppConfiguration.create(:config_key => key, :config_value => value)
  end

  def self.register_subdomain_with_modules subdomain
    AppConfiguration.create_for "site_id", subdomain.id
    AppConfiguration.create_for "site_url", subdomain.url
    AppConfiguration.create_for "site_title", subdomain.name
    # Load subdomain modules
    subdomain.properties.each do |key, value|
      AppConfiguration.create_for key, value
    end
  end

  def is_business_type_config?
    key = (self.config_key == "business_type") ? true : false
  end

  def setup_organization_structure
    # Add unittypes
    if self.config_value == "fnb" or self.config_value == "fnb_fd" or self.config_value == "fnb_qsr"
      Unittype.create([{:unit_type_name => "Distribution Center"}, {:unit_type_name => "Outlet"}])
    elsif self.config_value == "retail"
      Unittype.create([{:unit_type_name => "Distribution Center"}, {:unit_type_name => "Outlet"}])
    end
    # Add user roles
    if self.config_value == "fnb" or self.config_value == "fnb_qsr"
      Role.create([{:name => "dc_manager"}, {:name => "outlet_manager"}, {:name => "cashier"}])
    elsif self.config_value == "fnb_fd"
      Role.create([{:name => "dc_manager"}, {:name => "outlet_manager"}, {:name => "cashier"}, {:name => "waiter"}, {:name => "bartender"}])
    elsif self.config_value == "retail"
      Role.create([{:name => "dc_manager"}, {:name => "outlet_manager"}, {:name => "cashier"}])
    end
  end
end
