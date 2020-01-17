class ReservationSwapLog < ActiveRecord::Base
  attr_accessible :device_id, :new_resource_id, :old_resource_id, :reservation_id, :user_id, :unit_id
end
