class CreateInspectionQuestions < ActiveRecord::Migration
  def change
    create_table :inspection_questions do |t|
      t.integer :inspection_id
      t.integer :question_id
      t.text :question_title

      t.timestamps
    end
  end
end
