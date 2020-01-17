class CreateStockPrices < ActiveRecord::Migration
  def change
    create_table :stock_prices do |t|
      t.integer :stock_id
      t.integer :product_id
      t.float :landing_price
      t.float :mrp
      t.float :total_price_without_tax
      t.float :total_tax
      t.float :additional_cost
      t.float :total_price

      t.timestamps
    end
  end
end
