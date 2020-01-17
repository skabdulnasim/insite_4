class CreateStockUpdates < ActiveRecord::Migration
  def change
    create_table :stock_updates do |t|
      t.integer :store_id
      t.integer :product_id
      t.float :stock

      t.timestamps
    end
  end
end
