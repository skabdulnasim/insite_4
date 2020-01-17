class CreateStockDefinations < ActiveRecord::Migration
  def change
    create_table :stock_definations do |t|
      t.string :sku
      t.float :weight
      t.integer :received_product_unit
      t.float :sell_price
      t.float :making_cost
      t.float :wastage, :default => 0
      t.references :stock

      t.timestamps
    end
    add_index :stock_definations, :stock_id
  end
end
