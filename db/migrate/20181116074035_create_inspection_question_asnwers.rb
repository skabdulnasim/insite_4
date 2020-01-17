class CreateInspectionQuestionAsnwers < ActiveRecord::Migration
  def change
    create_table :inspection_question_asnwers do |t|
      t.integer :inspection_question_id
      t.integer :question_id
      t.integer :inspection_id
      t.integer :answer_id
      t.text :anwer_title

      t.timestamps
    end
  end
end
