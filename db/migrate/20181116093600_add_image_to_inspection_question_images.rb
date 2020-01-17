class AddImageToInspectionQuestionImages < ActiveRecord::Migration
  def change
  	add_attachment :inspection_question_images, :image
  end
end
