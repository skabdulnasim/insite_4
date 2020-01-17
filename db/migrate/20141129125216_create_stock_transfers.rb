class CreateStockTransfers < ActiveRecord::Migration
  def change
    create_table :stock_transfers do |t|
      t.integer :primary_store_id
      t.string :secondary_store_id
      t.integer :vehicle_id
      t.integer :vendor_id
      t.integer :invoice_id
      t.integer :activity_id
      t.string :status
      t.text :status_log
      t.timestamps
    end
  end
end
