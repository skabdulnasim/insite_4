class CreateWarehouseRacks < ActiveRecord::Migration
  def change
    create_table :warehouse_racks do |t|
      t.string :rack_unique_id
      t.integer :warehouse_metum_id
      t.string :row_unique_id

      t.timestamps
    end
  end
end
