class CreateInspectionQuestionImages < ActiveRecord::Migration
  def change
    create_table :inspection_question_images do |t|

      t.timestamps
    end
  end
end
