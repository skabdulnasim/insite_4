class Resource < ActiveRecord::Base
  has_attached_file :resource_image, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :resource_image, content_type: /\Aimage\/.*\z/
  
  # def initialize(attributes=nil, *args)
  #   super
  #   if new_record?
  #     # set default values for new records only
  #     initialized = (attributes || {}).stringify_keys
  #     if !initialized.key?('recorded_at')
  #       self.recorded_at = Time.now.utc
  #     else
  #       self.recorded_at = self.recorded_at.utc
  #     end
  #   end
  # end
  attr_accessible :name, :properties, :resource_type_id, :unit_id, :section_id, :resource_image, :resource_state_id, :parent_resource_id, :user_id, :status, :capacity, :price, :printer_id, :customer_id, :recorded_at, :unique_identity_no, :user_resources_attributes, :bit_resources_attributes, :beneficiaries_attributes, :menu_card_id, :menu_product_id
  belongs_to :resource_type
  belongs_to :resource_state
  has_many :availabilities
  has_many :orders, as: :deliverable
  #has_many :inspections
  belongs_to :additional_information, :class_name => "Section"
  belongs_to :section
  belongs_to :customer
  belongs_to :unit
  has_many :reservations
  has_many :user_resources, dependent: :destroy
  has_many :users, through: :user_resources
  has_many :visiting_histories
  has_many :inspections, as: :inspected_entity
  has_many :visiting_histories, as: :visited_entity
  has_many :resource_targets
  belongs_to :menu_card
  belongs_to :menu_product
  #  #commented due to rails4 migration
  has_many :bits, through: :bit_resources
  has_many :bit_resources
  has_many :beneficiaries, dependent: :destroy
  has_many :child_resources, :foreign_key => "parent_resource_id", :class_name => "Resource"
  has_many :user_sales
  accepts_nested_attributes_for :user_resources
  accepts_nested_attributes_for :bit_resources
  accepts_nested_attributes_for :beneficiaries

  # => Model validations
  # validates :name,        :presence => true
  # validates :unit_id,     :presence => true
  # validates :section_id,  :presence => true
  #validate :validate_properties

  # => Defining Bill statuses
  STATUS = %w(enabled disabled)
  
  # => Dynamic methods for bill statuses
  STATUS.each do |status|
    define_method "#{status}?" do
      self.status == status
    end
  end

  # => Dynamically defining these custom finder methods
  class << self
    STATUS.each do |status|
      define_method "#{status}" do
        where(["status=?", status])
      end
    end
  end

  def validate_properties
    resource_type.fields.each do |field|
      if field.required? && properties[field.name].blank?
        errors.add field.name, "must not be blank"
      end
    end
  end

  scope :by_unique_identity_no, lambda { |unique_identity_no| where(["unique_identity_no = ?",unique_identity_no]) }
  scope :by_unit,     lambda{|unit_id| where(["unit_id= ?",unit_id])}
  scope :by_unit_list, lambda{|unit_id_list| where(["unit_id IN(?)",unit_id_list])}
  scope :by_section,  lambda{|section_id| where(["section_id= ?",section_id])}
  scope :by_date,     lambda{|date| joins(:availabilities).merge(Availability.by_date(date).uniq("resource_id"))} 
  scope :by_resource_type, lambda{|resource_type_ids|where(["resource_type_id in (?)", resource_type_ids])}
  scope :set_state, lambda {|state_id|where(["resource_state_id=?", state_id])}
  scope :get_resource_name, lambda {|resource_id|where(["id=?",resource_id])}
  scope :name_like, lambda {|name| where(["lower(name) LIKE ?", "%#{name.downcase}%"])}
  scope :set_id_not_in, lambda {|resource_ids| where(["id not in (?)", resource_ids]) }
  scope :not_trash, lambda {|trash| where(["trash=?",0])}
  scope :disabled, lambda { where(:status => 'disabled') }
  scope :active_only, lambda { where(["status = ?",'enabled']) }
  scope :by_user, lambda {|user_id,day| joins(:user_resources).merge(UserResource.by_user(user_id).by_day(day))}
  scope :set_user, lambda {|user_id| joins(:user_resources).merge(UserResource.by_user(user_id))}
  scope :set_id , lambda {|id|where(["id=?", id])}
  scope :set_id_in , lambda {|id_list|where(["id in (?)", id_list])}
  scope :by_identification, lambda {|search_key| where(["name = :name OR unique_identity_no = :unique_identity_no",{name: search_key,unique_identity_no: search_key}])}
  scope :by_unique_identity,    lambda { |unique_identity| where(["unique_identity_no= ?",unique_identity]) }
  scope :get_root_resources, lambda { where(:parent_resource_id => nil) }
  scope :by_parent_resource , lambda {|parent_resource_id|where(["parent_resource_id=?", parent_resource_id])}
  scope :set_district, lambda {|district_id| where(["unique_identity_no LIKE ?", "#{district_id}/%"])}
  validates :unique_identity_no, :uniqueness => true, :if => Proc.new{self.unique_identity_no.present?}

  # Resource order swapping
  def self.set_district_ids_like(district_id_list)
    puts " district id list : #{district_id_list}"
    condition = ""
    i = district_id_list.length-1
    district_id_list.each_with_index do |dist_id,index|
      if i == index
        condition += "unique_identity_no LIKE '#{dist_id}/%'"
      else
        condition += "unique_identity_no LIKE '#{dist_id}/%' OR "
      end
    end
    puts "condition : #{condition}"
    resources = Resource.where(condition)
    p resources
  end
  def self.swap_resource_orders _order_ids, _new_resource, _old_resource, _device_id, _user_id, _unit_id
    _order_ids.each do |order|
      _order = Order.find(order['order_id'].to_i)
      _order.update_attributes(:deliverable_id => _new_resource.id) if _order.deliverable_type == "Resource"
      ResourceSwapLog.create(:device_id=>_device_id, :new_resource_id=>_new_resource.id, :old_resource_id=>_old_resource.id, :order_id=>_order.id, :user_id=>_user_id, :old_resource_state_before_update=>_old_resource.resource_state_id, :new_resource_state_before_update=>_new_resource.resource_state_id)
    end
    Resource.update_resource_state(2,_unit_id,_new_resource.id,_user_id,_device_id) #Change state of new resource
    Resource.update_resource_state(1,_unit_id,_old_resource.id,_user_id,_device_id) #Change state of old resource
  end

  # Update resource state
  def self.update_resource_state(_resource_state_id,_unit_id,_resource_id,_user_id,_device_id)
    _state = ResourceState.find(_resource_state_id)
    _resource = Resource.find(_resource_id)
    _resource.update_attributes(:resource_state_id => _resource_state_id, :user_id => _user_id)
    _status_log = ResourceStatusLog.new(:outlet_id => _unit_id, :resource_id => _resource_id, :resource_state_id => _state.id, :resource_state_name => _state.name, :resource_type_id => _resource.resource_type.id, :user_id => _user_id, :device_id => _device_id)
    _status_log.save
    Resource.push_resource_status_update _resource.reload,_status_log
    return _status_log
  end

  def self.import(file,user_id)
    CSV.foreach(file.path, headers: true) do |row|
      customer = Customer.find_by_mobile_no(row["Customer Mobile No"])
      section = Section.by_section_name(row["Section Name"]) if row["Section Name"].present?
      unit = section.first.unit
      resource_type = ResourceType.by_resource_type_name(row["Resource Type"])
      resource = Resource.find_by_name(row["Resource Name"])
      if resource.present?
        resource.attributes = {:unique_identity_no => row["Unique Identity No"], :resource_type_id => resource_type.first.id, :unit_id => unit.id,:section_id => section.first.id, :user_id => user_id, :status => 'enabled', :resource_state_id => 1, :capacity => row["Resource Capacity"], :price => row["Resource Price"],:printer_id => row["Printer Id"], :customer_id => customer.id}
      else
        resource = Resource.new
        resource.attributes = {:name => row["Resource Name"], :unique_identity_no => row["Unique Identity No"], :resource_type_id => resource_type.first.id, :unit_id => unit.id,:section_id => section.first.id, :user_id => user_id, :status => 'enabled', :resource_state_id => 1, :capacity => row["Resource Capacity"], :price => row["Resource Price"],:printer_id => row["Printer Id"], :customer_id => customer.id,}
      end
      if resource.save
        if row["Bit Name"].present?
          bit = Bit.by_bit_name(row["Bit Name"])
          BitResource.create(:bit_id=>bit.first.id , :resource_id=> resource.id)
        end  
      end  
    end
  end

  def self.dump_to_csv(_resources)
    attributes = %w{id name unique_identity_no}
    CSV.generate(headers: true) do |csv|
      csv << attributes
      _resources.each do |resource|
        csv << attributes.map{ |attr| resource.send(attr) }
      end
    end
  end

  def self.filter_by_string(searcing_text)
    if searcing_text.present?
      where("lower(name) LIKE ?", "%#{searcing_text.downcase}%")
    else
      all
    end
  end
  
  private  

  def self.push_resource_status_update resource,status_log
    _subdomain = AppConfiguration.find_by_config_key('site_id')
    _channels = Array.new
    _channels.push '/notifications/android/subdomain/'+_subdomain.config_value.to_s+'/unit/'+resource.unit_id.to_s+'/resource_state_update'
    _channels.push '/notifications/portal/subdomain/'+_subdomain.config_value.to_s+'/unit/'+resource.unit_id.to_s+'/resource_state_update'
    _hash = {:resource => resource, :status_log => status_log}
    Notification.publish_in_faye(_channels,_hash)    
  end

end
