class User < ActiveRecord::Base
  require "mac-address"
  audited
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  #devise :cas_authenticatable, :registerable,:recoverable, :rememberable, :trackable

  devise :database_authenticatable, :registerable,:recoverable, :rememberable, :trackable, :validatable

  # Attribute macros
  attr_accessible :status, :email,:encrypted_password, :password, :password_confirmation, :remember_me, :unit_id, :key_phrase, :profile_attributes, :users_role_attributes, :parent_user_id, :custom_sync

  # Association macros

  belongs_to :unit
  has_one :zone
  has_one :area
  has_one :role, :through => :users_role
  has_one :profile, :dependent => :destroy
  has_one :users_role
  has_many :orders, as: :consumer
  has_many :bills, as: :biller
  has_many :settlements, as: :client
  has_many :bill_reprints
  has_many :resources, through: :user_resources
  has_many :user_resources, dependent: :destroy
  has_many :user_bits, dependent: :destroy
  has_many :inspections
  has_many :visiting_histories
  has_many :user_login_logouts
  has_many :user_vendors
  has_many :child_users, :foreign_key => "parent_user_id", :class_name => "User"
  has_many :own_targets, :foreign_key => "child_user_id", :class_name => "UserTarget"
  has_many :child_user_targets, :foreign_key => "parent_user_id", :class_name => "UserTarget"
  has_many :live_map_points
  has_many :stores
  has_many :approvals
  belongs_to :parent_user, :foreign_key => "parent_user_id", :class_name => "User"
  # Validation macros
  validates :email, uniqueness: true
  # validates :auth_token, uniqueness: true

  # Callbacks
  before_create :generate_keyphase!
  before_validation :set_attributes


  Warden::Manager.before_logout do |user,auth,opts|
    if user.present?
      user_login_logouts = UserLoginLogout.by_user_id(user.id)
      if user_login_logouts.present?
        UserLoginLogout.by_user_id(user.id).by_device_identity(MacAddress.address).last.update_column(:sign_out_at, Time.now) if UserLoginLogout.by_user_id(user.id).by_device_identity(MacAddress.address).present?
      end
    end
  end


  # Nested forms
  accepts_nested_attributes_for :profile, allow_destroy: true
  accepts_nested_attributes_for :users_role, allow_destroy: true

  include Devise::Models::DatabaseAuthenticatable
  scope :by_user_id_in, lambda {|ids|where(["id IN(?)", ids])}
  scope :by_email, lambda { |email| where(["email = ?",email]) }
  scope :by_role, lambda { |role_id| joins(:users_role).merge(UsersRole.find_by_role(role_id))}
  scope :set_role, lambda{|role_ids| joins(:users_role).merge(UsersRole.set_role_in(role_ids))}
  scope :by_unit, lambda { |unit_id| where(["unit_id = ?", unit_id])}
  scope :by_id, lambda {|id| where(["id=?",id])}
  scope :by_user, lambda{|user_id| where(["id= ?",user_id])}
  scope :by_role_name, lambda { |role_name| joins(:users_role).merge(UsersRole.by_role_name(role_name))}
  scope :by_name, lambda {|name| joins(:profile).merge(Profile.name_like(name))}
  scope :by_date_range, lambda {|from_date, upto_date|where('created_at BETWEEN ? AND ?',from_date,upto_date)}
  scope :set_unit, lambda{|unit_ids| where(["unit_id in (?)",unit_ids])}
  scope :set_user, lambda{|user_ids| where(["id in (?)",user_ids])}
  scope :set_parent, lambda{|parent_user_id| where(["parent_user_id = ?",parent_user_id])}
  scope :by_status, lambda{|status_code| where (["status=?",status_code])}
  def as_json(options={})
    {
      :id => id,
      :email => email,
      :is_trashed => is_trashed,
      :key_phrase => key_phrase,
      :status => status,
      :created_at => created_at,
      :unit_id => unit_id
    }
  end

  def self.save_user_role(user_id, role_id)
    _user_role = UsersRole.new
    _user_role[:user_id] = user_id
    _user_role[:role_id] = role_id
    _user_role.save
  end

  def self.filter_by_unit(units)
    if !units.empty?
      where('unit_id IN(?)',units)
    else
      all
    end
  end

  def self.filter_by_user_status(user_statuses)
    if !user_statuses.empty?
      where('status IN(?)',user_statuses)
    else
      all
    end
  end

  def self.filter_by_string(searcing_text)
    if searcing_text.present?
      where("lower(email) LIKE ?", "%#{searcing_text.downcase}%")
    else
      all
    end
  end

  def self.has_parent?(user,user_collection)
    user.parent_user_id.nil? || !user_collection.where("id=?",user.parent_user_id).present? ? false : true
  end
  def self.has_child(id)
    User.where("parent_user_id=?",id).present? ? true : false 
  end
  def self.user_children(id)
    User.where("parent_user_id=?",id)
  end
  def update_token!
    generate_authentication_token!
    self.save
  end


  def after_database_authentication
    UserLoginLogout.create(:user_role_name => self.users_role.role.name, :unit_id => self.unit_id, :unit_name => self.unit.unit_name, :sign_in_at => Time.now.utc, :user_id => self.id, :device_identity => MacAddress.address)
  end
 
  def self.set_user_ids(parent_user_id,arr_user_id) # Recursion by ABDUL to get all user id from children chain
    arr_user_id.push(parent_user_id)
    @c_users = User.set_parent(parent_user_id)

    @c_users.each do |cu|
      User.set_user_ids(cu.id,arr_user_id) # Recursion call
    end
    return arr_user_id
  end

  private
 

  def set_attributes
    if new_record?
      generate_authentication_token!
      self.key_phrase ||= rand(10000)
    end
  end

  def generate_authentication_token!
    begin
      self.auth_token = Devise.friendly_token
    end while self.class.exists?(auth_token: auth_token)
  end

  def generate_keyphase!
    self.key_phrase = rand(10000)
  end

  def register_user_in_cas!
    _subdomain_id = AppConfiguration.get_config_value('site_id')
    _subdomain = Subdomain.find(_subdomain_id.to_i)
    @cas_member = find_member_in_cas
    _site_url_json = generate_site_url_json_data _subdomain # Generate site url json data
    if @cas_member.present?
      @cas_member.update_attribute(:site_url, _site_url_json)
    else
      pepper = nil
      cost = 10
      _encrypted_password = ::BCrypt::Password.create("#{self.password}#{pepper}", :cost => cost).to_s
      @cas_member = Member.new(:email => self.email, :encrypted_password => _encrypted_password,:site_url => _site_url_json)
    end
    _subdomain.members << @cas_member
  end

  def self.fetch_parent_from_role(role)
    
    type_info = Unit.where(:unittype_id => ids)
    return type_info
  end

  # Check if the user is present in CAS or not
  def find_member_in_cas
    Member.find_by_email(self.email)
  end

  def generate_site_url_json_data _subdomain
    _member = find_member_in_cas
    _site_array = _member.present? ? JSON.parse(_member.site_url) : Array.new
    _site_hash = {:site_url => _subdomain.url, :site_title => _subdomain.name}
    #_site_hash = {:site_url => _subdomain.url, :site_url => _subdomain.url, :site_title => _subdomain.name} #commented due to rails migration
    _site_array.push(_site_hash)
    _site_json = JSON.generate(_site_array)
  end

  def self.import(file)
    imported_users =Array.new
    data_errors = Array.new
    CSV.foreach(file.path, headers: true) do |row|
      user = find_by_id(row["id"]) || new
      _api_base_url = "http://#{(AppConfiguration.get_config_value('site_url')).to_s}/"
      _unit = Unit.by_unit_name(row["unit"]).first
      _role_id = Role.find_by_name(row["role"]).id
      case row["role"]
        when "owner"
          user.attributes = {:email=>row["email"], :password=>row["password"], :status=>row["status"], :parent_user_id=>"", :profile_attributes=>{:firstname=>row["first_name"], :lastname=>row["last_name"], :contact_no=>row["contact_no"], :appurl=>_api_base_url, :address=>row["address"], :city=>row["city"], :zip_code=>row["zip"], :state=>row["state"], :country=>row["country"]}, :users_role_attributes=>{:role_id=>_role_id}, :unit_id=>_unit.id}
        when "dc_manager"
          _parent_user_role_name = User.find_by_email(row["parent_user_email"]).role.name
          _parent_user_id=User.find_by_email(row["parent_user_email"]).id
          if(_parent_user_role_name == "owner")
            user.attributes = {:email=>row["email"], :password=>row["password"], :status=>row["status"], :parent_user_id=>_parent_user_id, :profile_attributes=>{:firstname=>row["first_name"], :lastname=>row["last_name"], :contact_no=>row["contact_no"], :appurl=>_api_base_url, :address=>row["address"], :city=>row["city"], :zip_code=>row["zip"], :state=>row["state"], :country=>row["country"]}, :users_role_attributes=>{:role_id=>_role_id}, :unit_id=>_unit.id}
          end
        when "outlet_manager"
          _parent_user_role_name = User.find_by_email(row["parent_user_email"]).role.name
          _parent_user_id=User.find_by_email(row["parent_user_email"]).id
          if(_parent_user_role_name == "dc_manager")
            user.attributes = {:email=>row["email"], :password=>row["password"], :status=>row["status"], :parent_user_id=>_parent_user_id, :profile_attributes=>{:firstname=>row["first_name"], :lastname=>row["last_name"], :contact_no=>row["contact_no"], :appurl=>_api_base_url, :address=>row["address"], :city=>row["city"], :zip_code=>row["zip"], :state=>row["state"], :country=>row["country"]}, :users_role_attributes=>{:role_id=>_role_id}, :unit_id=>_unit.id}
          end
        when "bill_manager"
          _parent_user_role_name = User.find_by_email(row["parent_user_email"]).role.name
          _parent_user_id=User.find_by_email(row["parent_user_email"]).id
          if(_parent_user_role_name == "outlet_manager")
            user.attributes = {:email=>row["email"], :password=>row["password"], :status=>row["status"], :parent_user_id=>_parent_user_id, :profile_attributes=>{:firstname=>row["first_name"], :lastname=>row["last_name"], :contact_no=>row["contact_no"], :appurl=>_api_base_url, :address=>row["address"], :city=>row["city"], :zip_code=>row["zip"], :state=>row["state"], :country=>row["country"]}, :users_role_attributes=>{:role_id=>_role_id}, :unit_id=>_unit.id} 
          end
        when "mall_client"
          _parent_user_role_name = User.find_by_email(row["parent_user_email"]).role.name
          _parent_user_id=User.find_by_email(row["parent_user_email"]).id
          if(_parent_user_role_name == "outlet_manager")
            user.attributes = {:email=>row["email"], :password=>row["password"], :status=>row["status"], :parent_user_id=>_parent_user_id, :profile_attributes=>{:firstname=>row["first_name"], :lastname=>row["last_name"], :contact_no=>row["contact_no"], :appurl=>_api_base_url, :address=>row["address"], :city=>row["city"], :zip_code=>row["zip"], :state=>row["state"], :country=>row["country"]}, :users_role_attributes=>{:role_id=>_role_id}, :unit_id=>_unit.id} 
          end
        when "sale_person"
          _parent_user_role_name = User.find_by_email(row["parent_user_email"]).role.name
          _parent_user_id=User.find_by_email(row["parent_user_email"]).id
          if(_parent_user_role_name == "bill_manager")
            user.attributes = {:email=>row["email"], :password=>row["password"], :status=>row["status"], :parent_user_id=>_parent_user_id, :profile_attributes=>{:firstname=>row["first_name"], :lastname=>row["last_name"], :contact_no=>row["contact_no"], :appurl=>_api_base_url, :address=>row["address"], :city=>row["city"], :zip_code=>row["zip"], :state=>row["state"], :country=>row["country"]}, :users_role_attributes=>{:role_id=>_role_id}, :unit_id=>_unit.id}
          end
        else
          _parent_user_role_name = User.find_by_email(row["parent_user_email"]).role.name
          _parent_user_id=User.find_by_email(row["parent_user_email"]).id
          if(_parent_user_role_name == "outlet_manager")
            user.attributes = {:email=>row["email"], :password=>row["password"], :status=>row["status"], :parent_user_id=>_parent_user_id, :profile_attributes=>{:firstname=>row["first_name"], :lastname=>row["last_name"], :contact_no=>row["contact_no"], :appurl=>_api_base_url, :address=>row["address"], :city=>row["city"], :zip_code=>row["zip"], :state=>row["state"], :country=>row["country"]}, :users_role_attributes=>{:role_id=>_role_id}, :unit_id=>_unit.id}
          end
      end
      imported_users.push user
    end
    if imported_users.map(&:valid?).all?
      imported_users.each(&:save!)
      true
    else
      imported_users.each_with_index do |user, index|
        unless user.valid?
          errors_messages = self.error_messages_for(user)
          data_errors.push("Row #{index+2}: #{errors_messages}")
        end
      end
      error_str = data_errors.map { |e| e }.join(', ')
      raise "Data of #{data_errors.size} row(s) prevented the form being saved. #{error_str}"
    end
  end

  def self.error_messages_for(*objects)
    error_string = ""
    objects = objects.map {|o| o.is_a?(String) ? instance_variable_get("@#{o}") : o}.compact
    errors = objects.map {|o| o.errors.full_messages}.flatten
    error_string = errors.map { |e|  "#{e}" }.join(', ') if errors.any?
  end

end
