class InspectionQuestion < ActiveRecord::Base
  attr_accessible :inspection_id, :question_id, :question_title, :inspection_question_asnwers_attributes, :inspection_question_images_attributes

  # MOdel Association
  belongs_to :inspection
  belongs_to :question
  has_many :inspection_question_asnwers
  has_many :inspection_question_images
  
  # Nestted Model
  accepts_nested_attributes_for :inspection_question_asnwers 
  accepts_nested_attributes_for :inspection_question_images 

  # Model Callback
  after_create :update_title

  # Model scope
  

  def update_title
    self.update_attributes(:question_title=>self.question.title)
  end
end
