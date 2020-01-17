class Table < ActiveRecord::Base
  attr_accessible :capacity, :name, :table_shape, :table_type, :unit_id, :table_state_id, :groups, :last_bill_id, :section_id, :angle, :user_id, :status
                  :table_status_logs_attributes

  belongs_to :table_state
  has_many :orders, as: :deliverable
  has_many :chairs
  has_many :table_reservation_meta
  has_many :printers, as: :assignable
  has_many :table_status_logs
  belongs_to :additional_information, :class_name => "Section"
  belongs_to :section

  accepts_nested_attributes_for :table_status_logs

  # => Model validations
  validates :name,        :presence => true
  validates :unit_id,     :presence => true
  validates :section_id,  :presence => true
  validates :table_shape, :presence => true

  # => Model Callbacks
  after_create :chairs_create
  scope :by_unit_id,            lambda {|unit_id|where(["unit_id =(?)", unit_id])}  
  scope :find_table_by_section, ->(section_id,unit_id) { where("section_id=? AND unit_id=?",section_id,unit_id)}

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

  # => Model Scopes
  scope :unit_tables, lambda {|unit_id|where(["unit_id=?", unit_id]).order(:id)}
  scope :set_section, lambda {|section_id|where(["section_id=?", section_id])}
  scope :set_state, lambda {|state_id|where(["table_state_id=?", state_id])}
  # scope :find_table_by_section, ->(section_id,unit_id) { where("section_id=? AND unit_id=?",section_id,unit_id)}
  scope :get_ondate_tables, ->(date) { where('reservation_date =? AND status =?',date,"1") }
  scope :get_status, lambda { |section_id,table_state_id| 
    if table_state_id.present?
      where(:section_id => section_id, :table_state_id => table_state_id, :is_trashed => false).enabled.order('created_at')
    else
      where(:section_id => section_id, :is_trashed => false).enabled.order('created_at')
    end
  }
  scope :non_trashed, lambda { where(:is_trashed => false) }
  scope :trashed, lambda { where(:is_trashed => true) }

  def chairs_create
    self.capacity.to_i.times do
      self.chairs.create()
    end
  end

  # Table order swapping
  def self.swap_table_orders _order_ids, _new_table, _old_table, _device_id, _user_id, _unit_id
    _order_ids.each do |order|
      _order = Order.find(order['order_id'].to_i)
      _order.update_attributes(:deliverable_id => _new_table.id) if _order.deliverable_type == "Table"
      TableSwapLog.create(:device_id=>_device_id, :new_table_id=>_new_table.id, :old_table_id=>_old_table.id, :order_id=>_order.id, :user_id=>_user_id, :old_table_state_before_update=>_old_table.table_state_id, :new_table_state_before_update=>_new_table.table_state_id)
    end
    Table.update_table_state(2,_unit_id,_new_table.id,_user_id,_device_id) #Change state of new table
    Table.update_table_state(1,_unit_id,_old_table.id,_user_id,_device_id) #Change state of old table
  end

  def self.update_table_state(_table_state_id,_unit_id,_table_id,_user_id,_device_id)
    _state = TableState.find(_table_state_id)
    _table = Table.find(_table_id)
    _table.update_attributes(:table_state_id => _table_state_id, :user_id => _user_id)
    _status_log = TableStatusLog.new(:outlet_id => _unit_id, :table_id => _table_id, :table_state_id => _state.id, :table_state_name => _state.name, :user_id => _user_id, :device_id => _device_id)
    _status_log.save
    Table.push_table_status_update _table.reload,_status_log
    return _status_log
  end

  def self.get_floorplan(unit_id,section_id)
    florplan = {}
    florplan_array = []
    unit = Unit.find(unit_id)
    tables = Table.where(:unit_id => unit_id,:section_id => section_id) 
    florplan["unit"] = unit
    florplan["unit_details"] = unit.unit_detail
    florplan["table"] = tables
    florplan_array.push(florplan)
    return florplan_array
  end
  
  private  

  def self.push_table_status_update table,status_log
    _subdomain = AppConfiguration.find_by_config_key('site_id')
    _channels = Array.new
    _channels.push '/notifications/android/subdomain/'+_subdomain.config_value.to_s+'/unit/'+table.unit_id.to_s+'/table_state_update'
    _channels.push '/notifications/portal/subdomain/'+_subdomain.config_value.to_s+'/unit/'+table.unit_id.to_s+'/table_state_update'
    _hash = {:table => table, :status_log => status_log}
    Notification.publish_in_faye(_channels,_hash)    
  end

end
