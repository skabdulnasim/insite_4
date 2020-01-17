class CancelationCause < ActiveRecord::Base
  attr_accessible :title, :cancelation_policy_id

  # Model Relations
  belongs_to :cancelation_policy
end