class VisitingHistory < ActiveRecord::Base
  attr_accessible :day, :in_time, :latitude, :longitude, :out_time, :recorded_at, :resource_id, :user_id, :visiting_type, :visting_reason, :unit_id, :device_id, :visiting_remarks, :customer_state_id, :customer_id, :address_id, :visited_entity_type, :visited_entity_id
  audited
  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if initialized.key?('resource_id')
        self.visited_entity_id = self.resource_id
        self.visited_entity_type = 'Resource'
      end  
      if initialized.key?('visited_entity_type')
        self.visited_entity_type = self.visited_entity_type.capitalize
      end  
      if !initialized.key?('recorded_at')
        self.recorded_at = Time.now.utc
      else
        self.recorded_at = self.recorded_at.utc
      end
    end
  end

  API_KEY       = 'Q2JRePQw7py'
  MobileNo      = '919933648398'
  SenderID      = 'PEDLAR'
  message       = 'Thank you for your order with Yottolabs, Kolkata. Your Order ID is # "#{self.id}". Please give us 30 min to serve you fresh and hot food.'
  Message       = URI.encode(message)
  ServiceName   = 'TEMPLATE_BASED'
  API_BASE_URL  = "smsapi.24x7sms.com/api_2.0/SendSMS.aspx?APIKEY="

  #Model Callback
  after_create :update_customer
  #Model validation
  validates :latitude,     :presence => true
  validates :longitude,     :presence => true
  #validates :resource_id,     :presence => true
  validates :user_id,     :presence => true
  #Model Relation
  belongs_to :user
  belongs_to :resource
  belongs_to :unit
  belongs_to :customer
  belongs_to :visited_entity, polymorphic: true
  #Model Scope
  scope :by_day, lambda { |day| where(["day = ?",day]) }
  scope :by_user, lambda { |user_id| where(["user_id = ?",user_id]) }
  scope :today, lambda { where('date(recorded_at) =?',Date.today) }
  scope :before_noon, lambda { |time| where('recorded_at <=?',time)}
  scope :by_date, lambda { |date| where('date(recorded_at) =?',date)}
  scope :by_visiting_type, lambda { |visiting_type| where('visiting_type =?',visiting_type)}
  scope :by_visited_entity_type, lambda { |visited_entity_type| where('visited_entity_type =?',visited_entity_type)}
  scope :set_entity_ids,             lambda {|entity_ids| where(["visited_entity_id in (?)",entity_ids])}
  def self.by_recorded_at(from_date, upto_date)
    where('recorded_at BETWEEN ? AND ?',from_date,upto_date)
  end

  def update_customer
    self.customer.update_column(:customer_state_id, self.customer_state_id) if self.customer.present?
  end

  def self.send_sms
    @accounts = Account.all
    @accounts.each do |account|
      Apartment::Database.switch(account.subdomain)
      if AppConfiguration.get_config_value('send_notification_for_not_visiting') == 'enabled'
        todate = Date.today.strftime("%Y-%m-%d")
        time_today = "#{todate} 06:30:00"
        to_day = Time.now.strftime("%A")
        user_ids = UserResource.by_day(to_day).uniq.pluck(:user_id)
        if user_ids.present?
          user_ids.each do |user_id|
            user = User.find(user_id)
            if user.status == 1
              visiting_history = VisitingHistory.by_user(user_id).today.before_noon(time_today)
              if visiting_history.empty?
                _mobile_no = Array.new
                _roll_arr = Array.new
                #user = User.find(user_id)
                if User.has_parent?(user)
                  parentuser = User.find(user.parent_user_id)
                  _mobile_no.push("91#{parentuser.profile.contact_no}")
                else
                  bill_manager_role = Role.find_by_name("bill_manager")
                  _roll_arr.push(bill_manager_role.id)
                  _users = User.includes(:profile).set_role(_roll_arr)
                  _users.each do |user|
                    _mobile_no.push("91#{user.profile.contact_no}")
                  end 
                end   
                _mobile_no = _mobile_no.compact.reject(&:empty?).join(',')
                message = "Alert: Sale Executive, Mr.#{user.profile.firstname} #{user.profile.lastname} Contact no: #{user.profile.contact_no} has not started his job till now."
                #_mobile_no = "918902316887"
                message   = URI.encode(message)   
                uri = "http://#{API_BASE_URL}#{API_KEY}&MobileNo=#{_mobile_no}&SenderID=#{SenderID}&Message=#{message}&ServiceName=#{ServiceName}"   
                uri = URI.parse(uri)    
                rest_response = Net::HTTP.get_response(uri) 
                if user.profile.contact_no.present?
                  _umobile_no = "91#{user.profile.contact_no}"
                  message   = "It is 12 pm! and yet no action from your side! Come on, your peers are ahead of you!"
                  #_mobile_no = "919674442296,919163094937"
                  message   = URI.encode(message)   
                  uri = "http://#{API_BASE_URL}#{API_KEY}&MobileNo=#{_umobile_no}&SenderID=#{SenderID}&Message=#{message}&ServiceName=#{ServiceName}"   
                  uri = URI.parse(uri)    
                  rest_response = Net::HTTP.get_response(uri) 
                end 
              end 
            end   
          end   
        end  
      end  
    end  
  end
end
