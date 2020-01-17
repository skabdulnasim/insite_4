class ResourceStatusLog < ActiveRecord::Base
  attr_accessible :device_id, :outlet_id, :resource_id, :resource_state_id, :resource_state_name, :resource_type_id, :user_id
end
