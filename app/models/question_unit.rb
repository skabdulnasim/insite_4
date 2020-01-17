class QuestionUnit < ActiveRecord::Base

  attr_accessible :question_id, :unit_id

  # Model Relations
  belongs_to :question
  belongs_to :unit

  # Model Validations
  validates :question_id, :presence => true
  validates :unit_id, :presence => true

  #Model Scope
  scope :active_question, lambda{ joins(:question).merge(Question.active_mode())}
  scope :by_question_type, lambda{|question_type| joins(:question).merge(Question.by_question_type(question_type))}

  def self.save_unit_questions(q_id, unit_ids)
  	prev = self.where('question_id =?', q_id)
    prev.destroy_all if prev.present?
  	unit_ids.each do |unit_id|
  	  QuestionUnit.create(:question_id => q_id, :unit_id => unit_id)
	  end
  end

end