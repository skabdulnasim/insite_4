class Reservation < ActiveRecord::Base
  belongs_to :customer
  belongs_to :resource
  belongs_to :slot
  belongs_to :bill
  belongs_to :customer_queue
  belongs_to :unit
  has_one :check_information
  has_many :reservation_details

  accepts_nested_attributes_for :reservation_details
  
  scope :get_customers, lambda { |reservation_date,resource_id,slot_id| where(["resource_id = ? AND reservation_date = ? AND slot_id = ?", resource_id, reservation_date, slot_id])}
  scope :by_unit, lambda { |unit_id| where(["unit_id = ?", unit_id]) }
  scope :by_date, lambda { |date| where(["reservation_date = ?", date]) }
  scope :by_resource, lambda { |resource_id| where(["resource_id = ?", resource_id]) }
  scope :by_slot, lambda { |slot_id| where(["slot_id = ?", slot_id]) }
  scope :set_slot_in, lambda {|slot_ids|where(["slot_id in (?)", slot_ids])}
  scope :by_id, lambda {|id| where(["id =?", id])}
  scope :by_status, lambda {|status| where(["status =?", status])}
  scope :by_mobile, lambda {|mobile| where(["customer_mobile LIKE ?", "%#{mobile}%"])}
  scope :start_date, lambda {|start_date| where(["date(start_date) >= ?", start_date])}
  scope :end_date, lambda { |end_date| where(["date(end_date) <= ?", end_date]) }
  scope :by_date_range, lambda {|from_date, upto_date|where('date(start_date) BETWEEN ? AND ? OR date(end_date) BETWEEN ? AND ?',from_date,upto_date,from_date,upto_date)}
  scope :not_trash, lambda { |trash| where(["trash = ?", trash]) }
  scope :by_date_time_range, lambda {|from_date, upto_date|where('start_date BETWEEN ? AND ? OR end_date BETWEEN ? AND ?',from_date,upto_date,from_date,upto_date)}
  scope :not_checked_out, lambda {where("state !=?", "checked_out")}
  
  attr_accessible :pax, :reservation_date, :customer_id, :resource_id, :slot_id, :bill_id, :status, :start_time, :end_time, :unit_id, :customer_mobile, :start_date, :end_date, :trash, :customer_queue_id, :confirm_reservation_cancel, :source, :user_id, :device_id, :state, :reservation_details_attributes

  # Defining reservation sources
  _sources = %w(inhouse direct)
  SOURCES = _sources.freeze

  #Model callback
  after_create :update_customer_que,
               :update_reservation,
               :update_resource,
               :update_order,
               :create_check_information
  after_save :push_update_to_subscribers
  #model validation
  validates :source,            :presence => true
  # validates :resource_id,       :presence => true
  validates :unit_id,           :presence => true
  validates :customer_mobile,   :presence => true
  validates :pax,               :presence => true
  validates :device_id,         :presence => true
  validates :customer_queue_id, :presence => true
  validate  :validate_reservation

  def update_customer_que
    customer_queue = self.customer_queue
    _queue_state_id = 2
    _pax = customer_queue.pax
    _pax = customer_queue.pax - self.pax if customer_queue.pax >= self.pax
    _is_reserved = 0
    _is_reserved = 1 if _pax == 0
    _queue_state_id = 3 if _pax == 0
    customer_queue.update_attributes(:pax => _pax, :is_reserved => _is_reserved, :customer_queue_state_id => _queue_state_id, :reference_id => self.id)
  end

  # Custom validation for reservation
  def validate_reservation
    if new_record?
      ensure_reservation_pax_match
    end
  end

  def update_reservation
    customer_queue = self.customer_queue
    self.update_attributes(:start_date => customer_queue.from_date, :end_date => customer_queue.to_date, :slot_id => customer_queue.slot_id, :customer_id => customer_queue.customer_id)
  end

  def update_resource
    # Resource.update_resource_state(2, self.unit_id, self.resource_id, self.user_id, self.device_id)
  end

  # Checking stock status of every order items
  def ensure_reservation_pax_match
    # errors.add(:base, I18n.t(:error_pax_not_match)) if self.pax > self.resource.capacity
  end

  def self.swap_reservation _reservation, _new_resource, _old_resource, _device_id, _user_id, _unit_id
    ReservationSwapLog.create(:device_id=>_device_id, :new_resource_id=>_new_resource.id, :old_resource_id=>_old_resource.id, :reservation_id=>_reservation.id, :user_id=>_user_id, :unit_id =>_unit_id)
  end

  def self.reservation_report_csv(reservations)
    CSV.generate do |csv|
      _title = ["Slot", "Doctor", "Patient Name", "Phone No", "Appointment Time", "Status", "Amount", "Created at" ]
      csv << _title
      reservations.each do |object|
        if object.status == "1"
          status = "paid"
        else
          status = "unpaid"
        end  
        if object.bill.present?
          amount = object.bill.bill_amount 
        else  
          amount = "_"
        end  
        _row = Array.new
        _row.push("#{object.slot.title}")
        _row.push(object.resource.name)
        _row.push("#{object.customer.customer_profile.firstname} #{object.customer.customer_profile.lastname}")
        _row.push(object.customer.mobile_no)
        _row.push("#{object.start_time.strftime("%I:%M %p")}-" "#{object.end_time.strftime("%I:%M %p")} " "- (#{object.reservation_date})")
        _row.push(status)
        _row.push(amount)
        _row.push(object.created_at.strftime("%d-%m-%Y %I:%M %p"))
        csv << _row
      end
    end
  end

  def push_update_to_subscribers
    _subdomain = AppConfiguration.find_by_config_key('site_id')
    _channels = Array.new

    # Push notification for new customer queue *ANDROID*
    _channels = Array.new
    _channels.push '/notifications/android/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/reservations'
    _channels.push '/notifications/portal/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/reservations'
    Notification.publish_in_faye(_channels,{:reservations => self})
  end

  def update_order
    Order.update_deliverable(self) if self.customer_queue.reservations.count < 2
  end

  def create_check_information
    _check_information = CheckInformation.new({ :reservation_id => self.id, :status => "pending"})
    _check_information.save
  end
end
