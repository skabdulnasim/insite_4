class Slot < ActiveRecord::Base
  attr_accessible :duration, :end_time, :start_time, :title, :unit_id, :status, :max_booking, :start_date, :end_date, :slot_type
  has_many :availabilities
  belongs_to  :unit
  has_many :order_slots
  has_many :order_details

  SLOT_TYPE = %w( Standard Express )

  #Model scope
  scope :by_unit, lambda {|unit_id|where(["unit_id=?", unit_id])}
  scope :enabled, lambda { where(:status => 'enabled') }
  scope :by_slot_type, lambda {|slot_type|where(["slot_type=?", slot_type])}
end