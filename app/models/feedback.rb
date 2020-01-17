class Feedback < ActiveRecord::Base
  attr_accessible :title, :feedback_options_attributes
  has_many :feedback_options, dependent: :destroy
  has_many :unit_feedbacks, dependent: :destroy
  has_many :units, through: :unit_feedbacks
  has_many :feedback_customer_answer
  accepts_nested_attributes_for :feedback_options


  #class Validation
  validates :title, :presence => true

end
