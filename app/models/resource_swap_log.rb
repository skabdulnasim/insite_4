class ResourceSwapLog < ActiveRecord::Base
  attr_accessible :device_id, :new_resource_id, :new_resource_state_before_update, :old_resource_id, :old_resource_state_before_update, :order_id, :user_id
end
