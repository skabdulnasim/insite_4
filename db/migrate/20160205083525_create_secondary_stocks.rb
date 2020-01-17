class CreateSecondaryStocks < ActiveRecord::Migration
  def change
    create_table :secondary_stocks do |t|
      t.integer :stock_id
      t.integer :store_id
      t.integer :product_id
      t.integer :product_unit_id
      t.float :stock_credit
      t.float :stock_debit
      t.float :available_stock
      t.float :current_stock

      t.timestamps
    end
  end
end
