class AddInspectionQuestionIdToInspectionQuestionImages < ActiveRecord::Migration
  def change
    add_column :inspection_question_images, :inspection_question_id, :integer
  end
end
