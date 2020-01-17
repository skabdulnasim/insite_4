class CustomerFeedback < ActiveRecord::Base
  attr_accessible :email, :name, :phone, :unit_id, :customer_feedback_answers_attributes
  has_many :customer_feedback_answers
  accepts_nested_attributes_for :customer_feedback_answers
end
