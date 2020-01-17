class CreatePosTerminals < ActiveRecord::Migration
  def change
    create_table :pos_terminals do |t|
      t.string :name
      t.string :capability
      t.integer :unit_id

      t.timestamps
    end
  end
end
