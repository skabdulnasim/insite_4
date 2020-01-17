class CreateUnitFeedbacks < ActiveRecord::Migration
  def change
    create_table :unit_feedbacks do |t|
      t.integer :feebback_id
      t.integer :unit_id

      t.timestamps
    end
  end
end
