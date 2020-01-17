class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.integer :product_id
      t.integer :store_id
      t.float :quantity
      t.float :price
      t.float :available_stock
      t.text :consumption_log
      t.text :stock_status
      t.integer :stock_transaction_id

      t.timestamps
    end
  end
end
