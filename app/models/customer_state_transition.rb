class CustomerStateTransition < ActiveRecord::Base
  attr_accessible :customer_id, :customer_state_id, :recorder_at, :user_id,:customer_communications_attributes
  belongs_to :customer
  has_many :customer_communications
  belongs_to :customer_state
  accepts_nested_attributes_for :customer_communications
  scope :find_is_present, lambda{|customer_id,state_id|where(["customer_id=? and customer_state_id=?",customer_id,state_id])}
  scope :by_customer_id, lambda{|customer_id| where(["customer_id=?",customer_id])}
  def initialize(attributes=nil, *args)
    super
    if new_record?               
      if !self.recorded_at.present?
      	self.recorded_at = Time.now.utc
      end
    end
  end
end
