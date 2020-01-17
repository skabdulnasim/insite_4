class CreateSorts < ActiveRecord::Migration
  def change
    create_table :sorts do |t|
      t.string :name
      t.string :description
      t.integer :unit_id

      t.timestamps
    end
  end
end
