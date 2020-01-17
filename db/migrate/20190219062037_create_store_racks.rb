class CreateStoreRacks < ActiveRecord::Migration
  def change
    create_table :store_racks do |t|
      t.string :name
      t.float :height
      t.float :width
      t.references :store

      t.timestamps
    end
    add_index :store_racks, :store_id
  end
end
