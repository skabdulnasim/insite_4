class CreateModelActions < ActiveRecord::Migration
  def change
    create_table :model_actions do |t|
      t.string :name
      t.integer :master_model_id
      t.string :status

      t.timestamps
    end
  end
end
