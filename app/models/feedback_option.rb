class FeedbackOption < ActiveRecord::Base
  attr_accessible :option_title, :feedback_id
  belongs_to :feedback
  validates :option_title, :presence => true
end
