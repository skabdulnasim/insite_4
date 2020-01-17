class CustomerTag < ActiveRecord::Base
  attr_accessible :customer_id, :tag_id
  belongs_to :customer
  belongs_to :tag
  scope :is_present, lambda{|customer_id,tag_id|where(["customer_id=? AND tag_id=?",customer_id,tag_id])}
  scope :by_customer_id, lambda{|customer_id| where(["customer_id=?",customer_id])}
end
