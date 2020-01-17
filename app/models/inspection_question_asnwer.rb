class InspectionQuestionAsnwer < ActiveRecord::Base
  attr_accessible :answer, :inspection_id, :inspection_question_id, :question_id, :option_id

  # MOdel Association
  belongs_to :inspection
  belongs_to :option
  # Model Callback
  after_create :update_answer

  def update_answer
  	self.update_attributes(:answer=>self.option.title) if self.option_id.present?
  end
end
