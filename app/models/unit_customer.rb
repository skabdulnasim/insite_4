class UnitCustomer < ActiveRecord::Base
  attr_accessible :customer_id, :unit_id
  # class validations
  validates :unit_id, :presence => true
  validates :customer_id, :presence => true

  # class relations
  belongs_to :unit
  belongs_to :customer

  scope :find_by_unit, lambda { |unit_id| where(["unit_id = ?",unit_id]) }

  def self.save_unit_customers(c_id, unit_ids)
  	prev = self.where('customer_id =?', c_id)
    prev.destroy_all if prev.present?
  	unit_ids.each do |unit_id|
  	  UnitCustomer.create(:customer_id => c_id, :unit_id => unit_id)
	  end
  end
end
