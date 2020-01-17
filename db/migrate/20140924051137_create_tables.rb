class CreateTables < ActiveRecord::Migration
  def change
    create_table :tables do |t|
      t.string :name
      t.string :shape
      t.string :capacity
      t.string :type
      t.integer :unit_id

      t.timestamps
    end
  end
end
