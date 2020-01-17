class DeliveryCharge < ActiveRecord::Base
  attr_accessible :delivery_charge, :lower_limit, :unit_id, :upper_limit
end
