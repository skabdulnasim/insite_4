class Customer < ActiveRecord::Base
	devise :database_authenticatable, :registerable,:recoverable, :rememberable, :trackable, :validatable
  attr_accessible :email, :mobile_no, :customer_profile_attributes, :addresses_attributes, :customer_queues_attributes, :resource_attributes, :encrypted_password, :password, :gstin, :business_type, :customer_unique_id, :fb_id, :customer_state_id
  #validates :email, :uniqueness => true
  #validates :email, :presence => false
	has_one :customer_profile
  has_one :additional_information, :class_name => "CustomerProfile"
  has_one :wallet
  has_one :profile, :class_name => "CustomerProfile"
  has_one :resource
  has_many :beneficiaries, :through=>:resource
  has_many :addresses
  has_many :orders, as: :consumer
	has_many :bills, as: :biller
  has_many :parties
  has_many :orders, as: :deliverable
	has_many :settlements, as: :client
  has_many :bills
  has_many :customer_queues
  has_many :unit_customers, dependent: :destroy
  has_many :units, through: :unit_customers
  belongs_to :customer_state
  has_many :tags,through: :customer_tag
  has_many :customer_notes
  belongs_to :customer_state
  has_many :customer_logs
  has_many :customer_state_transitions
  has_many :proformas
  #has_many :otps, foreign_key: :phone_number, primary_key: :mobile_no
  has_one :financial_account,  as: :account_holder
  has_one :order_cart
  accepts_nested_attributes_for :customer_profile
  accepts_nested_attributes_for :addresses
  accepts_nested_attributes_for :customer_queues
  accepts_nested_attributes_for :resource

  #Model callback
  after_create :send_email

  scope :by_identification, lambda {|login| where(["email = :email OR mobile_no = :mobile_no",{email: login,mobile_no: login}])}
  scope :by_unit, lambda { |unit_id| joins(:unit_customers).merge(UnitCustomer.find_by_unit(unit_id))}
  scope :by_email_mobile,   lambda {|login| where(["email ILIKE ? OR mobile_no ILIKE ?","%#{login}%","%#{login}%"])}
  scope :search,            lambda{|data| joins("LEFT OUTER JOIN customer_profiles ON customers.id=customer_profiles.customer_id").where(["email ILIKE ? OR mobile_no ILIKE ? OR customer_name ILIKE ? OR firstname ILIKE ? OR lastname ILIKE ?","%#{data}%","%#{data}%", "%#{data}%","%#{data}%","%#{data}%"])}
  scope :by_customer_name_search,  lambda{|cust_name| joins("LEFT OUTER JOIN customer_profiles ON customers.id=customer_profiles.customer_id").where(["customer_profiles.customer_name ILIKE ? ","%#{cust_name}%"])}
  scope :by_mobile, lambda {|mobile_no| where(["mobile_no=?",mobile_no])}
  scope :set_id, lambda {|ids|where(["id in (?)", ids])}
  scope :reverse,  -> { order('created_at ASC') }
  scope :search_resource,            lambda{|data| joins("LEFT OUTER JOIN resources ON customers.id=resources.customer_id").where(["resources.name ILIKE ? OR resources.unique_identity_no ILIKE ?","#{data}%","%#{data}%"])}
  
  nilify_blanks :only => [:mobile_no, :email, :encrypted_password, :password]

  #Email / mobile no need to be exist
  def email_required?
    super && mobile_no.blank?
  end

  validates :mobile_no, :uniqueness => true
  #validates :mobile_no, :presence => false
  validates :mobile_no, numericality: true, length: {:minimum => 10, :maximum => 14}, :if => Proc.new{self.mobile_no.present?}

  def login=(login)
    @login = login
  end

  def login
    @login || self.mobile_no || self.email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(mobile_no) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions.to_h).first
    end
  end

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      customer = Customer.new
      unit = Unit.by_unit_name(row["Unit Name"]) if row["Unit Name"].present?
      customer.attributes = {"mobile_no"=>row["Mobile No"], "password"=>"12345678","gstin"=>row["GST No"], "customer_profile_attributes"=>{"firstname"=>row["First Name"], "lastname"=>row["Last Name"], "pan_no"=>row["Pan No"], "alternate_name"=>row["Alternate Name"], "alternate_mobile"=>row["Alternate Mobile No"], "gender"=>row["Gender"], "dob"=>row["DOB"]}, "addresses_attributes"=>{"0"=>{"delivery_address"=>row["Delivery Address"], "pincode"=>row["Pincode"], "landmark"=>row["Landmark"], "locality"=>row["Locality"], "city"=>row["City"], "state"=>row["State"]}}, "resource_attributes"=>{"resource_type_id"=>ResourceType.by_resource_type_name(row["Resource Type"]).first.id, "name"=>row["Resource Name"], "capacity"=>row["Resource Capacity"], "price"=>row["Resource Price"], "printer_id"=>row["Printer id"], "section_id"=>Section.by_section_name(row["Section Name"]).first.id, "resource_state_id"=>1, "unit_id"=>Unit.by_unit_name(row["Unit Name"]).first.id, "status"=>row["Status"], "unique_identity_no"=>row["Unique Identity No"]}}
      if customer.save 
        if unit.present?
          UnitCustomer.create(:unit_id => unit.first.id, :customer_id => customer.id)
        end
        if row["Bit Name"].length > 0
          bit = Bit.by_bit_name(row["Bit Name"])
          BitResource.create(:bit_id=>bit.first.id , :resource_id=> customer.resource.id)
        end   
      end  
    end
  end

  private

  def send_email
    if AppConfiguration.get_config_value('send_welcome_to_customer') == 'enabled'
      CustomerMailer.welcome_mail_to_customer(self).deliver
    end 
    if AppConfiguration.get_config_value('email_to_admin_customer_register') == 'enabled'
      CustomerMailer.new_customer_to_admin(self).deliver
    end 
  end

end