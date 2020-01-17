class UserTargetProduct < ActiveRecord::Base
  attr_accessible :product_id, :target_quantity, :user_target_id
  belongs_to :user_target
  belongs_to :product
  belongs_to :resource_target
end
