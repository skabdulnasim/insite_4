class CustomerCommunication < ActiveRecord::Base
  attr_accessible :communication_details, :communication_medium, :customer_id, :recorded_at, :user_id, :customer_state_transition_id
  belongs_to :customer_state_transition
  after_create  :set_additional_informations
  
  def set_additional_informations
    if self.user_id.present?
      update_attributes(customer_id:self.customer_state_transition.customer_id)
    else
       update_attributes(customer_id:self.customer_state_transition.customer_id, user_id:self.customer_state_transition.user_id)
    end
  end
  
  def initialize(attributes=nil, *args)
    super
    if new_record?               
      if !self.recorded_at.present?
        self.recorded_at = Time.now.utc
      end
    end
  end
end
