class CreateQuestionUnits < ActiveRecord::Migration
  def change
    create_table :question_units do |t|
      t.references :question
      t.references :unit

      t.timestamps
    end
    add_index :question_units, :question_id
    add_index :question_units, :unit_id
  end
end
