class ReturnCause < ActiveRecord::Base
  attr_accessible :title, :return_policy_id

  # Model Relations
  belongs_to :return_policy
end