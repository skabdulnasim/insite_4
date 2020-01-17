class Availability < ActiveRecord::Base
  belongs_to :slot
  belongs_to :resource
  attr_accessible :available_date
  before_save :check_availability

  scope :by_date, lambda { |date| where(["available_date = ?", date]) }
  scope :by_slot, lambda { |slot_id| where(["slot_id = ?", slot_id]) }
  scope :by_resource, lambda { |resource_id| where(["resource_id = ?", resource_id]) }
  

  def self.distinct_resource_by_date(date)
    where(["available_date = ?", date]).select(:resource_id).uniq
  end

  def self.distinct_avaliable_resource(date)
    where(["available_date = ?", date]).select(:resource_id).uniq
  end

  private

  def check_availability
  	available = Availability.by_date(self.available_date).by_slot(self.slot.id).by_resource(self.resource.id)
  	raise 'Availability already saved.' unless available.blank?
  end

end
