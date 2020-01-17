class DeliveryAddressesUnit < ActiveRecord::Base
  attr_accessible :delivery_address_id, :unit_id
  belongs_to  :unit
  belongs_to  :delivery_address

  validates :unit_id, :presence => true
  validates :delivery_address_id, :presence => true

  scope :find_by_address_unit, lambda { |unit_id| where(["unit_id = ?",unit_id]) }
  scope :set_delivery_address_id_in, lambda {|delivery_address_ids|where(["delivery_address_id in (?)", delivery_address_ids])}


  def self.save_unit_delivery(delivery_id, unit_ids)
  	deliver = self.where('delivery_address_id =?', delivery_id)
  	unit_ids.each do |unit_id|
  		DeliveryAddressesUnit.create(:delivery_address_id => delivery_id, :unit_id => unit_id)
    end
	end

end
