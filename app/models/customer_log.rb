class CustomerLog < ActiveRecord::Base
  attr_accessible :customer_id, :customer_state_id, :recorded_at, :tag_id
  belongs_to :customer
end
