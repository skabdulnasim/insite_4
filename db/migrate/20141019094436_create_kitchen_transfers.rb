class CreateKitchenTransfers < ActiveRecord::Migration
  def change
    create_table :kitchen_transfers do |t|
      t.integer :kitchen_store_id
      t.integer :from_store
      t.integer :product_id
      t.float :stock_credit
      t.text :transaction_id
      t.text :status
      t.text :status_log

      t.timestamps
    end
  end
end
