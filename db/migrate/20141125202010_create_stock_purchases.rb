class CreateStockPurchases < ActiveRecord::Migration
  def change
    create_table :stock_purchases do |t|
      t.integer :purchase_order_id
      t.integer :store_id
      t.string :status
      t.text :status_log

      t.timestamps
    end
  end
end
