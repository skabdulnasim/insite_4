class CustomerQueue < ActiveRecord::Base
  attr_accessible :from_date, :to_date, :pax, :customer_id, :trash, :total_pax, :is_reserved, :unit_id, :is_preauth, :slot_id, :customer_queue_state_id, :preauth_value, :transaction_id, :reference_id

  #Model association
  belongs_to :customer
  has_many :reservations
  belongs_to :unit
  belongs_to :customer_queue_state
  #has_one :preauth
  belongs_to :slot
  has_many :orders
  has_many :preauths, as: :advance
  #Model validation
  validates :unit_id, :presence => true
  validates :customer_queue_state_id, :presence => true
  validates :pax, :presence => true
  validates :slot_id, :presence => true

  #Model callback 
  after_save :push_update_to_subscribers

  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('from_date')
        self.from_date = Time.now.utc
      else
        self.from_date = self.from_date.utc
      end
      if !initialized.key?('to_date')
        self.to_date = Time.now.utc
      else
        self.to_date = self.to_date.utc
      end
    end
  end

  scope :set_trash, lambda { |trash| where(["trash = ?", trash]) }
  scope :set_is_reserved, lambda { |is_reserved| where(["is_reserved = ?", is_reserved]) }
  scope :set_unit_id, lambda { |unit_id| where("unit_id = ?", unit_id) }
  scope :set_customer_id, lambda { |customer_id| where("customer_id = ?", customer_id) }
  scope :by_date, lambda { |date| where("date(from_date)=?", date) }
  scope :by_slot, lambda {|slot_id| where("slot_id=?",slot_id)}
  scope :is_preauth, lambda {where(["is_preauth = ?", true]) }
  scope :by_unit, lambda{|unit_id| where(["unit_id= ?",unit_id])}
  scope :set_slot_id_in, lambda {|slot_ids| where(["slot_id in (?)", slot_ids]) }
  scope :by_is_preauth, lambda{|is_preauth| where(["is_preauth = ?", is_preauth]) }
  scope :is_reserved, lambda{ |is_reserved| where(["is_reserved =?", is_reserved]) }
  scope :by_id, lambda{|id| where("id=?", id)}
  def push_update_to_subscribers
    _subdomain = AppConfiguration.find_by_config_key('site_id')
    _channels = Array.new

    # Push notification for new customer queue *ANDROID*
    _channels = Array.new
    _channels.push '/notifications/android/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/custmer_queue'
    _channels.push '/notifications/portal/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/custmer_queue'
    Notification.publish_in_faye(_channels,{:customer_queue => self})
  end
end
