class CustomerNote < ActiveRecord::Base
  attr_accessible :customer_id, :notes, :recorded_at
  belongs_to :customer
  def initialize(attributes=nil, *args)
    super
    if new_record?               
      if !self.recorded_at.present?
        self.recorded_at = Time.now.utc
      end
    end
  end
end

