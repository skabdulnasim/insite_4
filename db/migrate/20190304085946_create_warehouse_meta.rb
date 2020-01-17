class CreateWarehouseMeta < ActiveRecord::Migration
  def change
    create_table :warehouse_meta do |t|
      t.integer :row_unique_id
      t.integer :store_id

      t.timestamps
    end
  end
end
