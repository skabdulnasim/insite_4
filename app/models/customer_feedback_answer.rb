class CustomerFeedbackAnswer < ActiveRecord::Base
  attr_accessible :customer_feedback_id, :feedback_id, :feedback_option_id
  belongs_to :customer_feedback
  belongs_to :feedback
  belongs_to :feedback_option
end
