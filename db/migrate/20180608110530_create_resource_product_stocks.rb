class CreateResourceProductStocks < ActiveRecord::Migration
  def change
    create_table :resource_product_stocks do |t|
      t.integer :resource_id
      t.integer :user_id
      t.integer :product_id
      t.float :stock
      t.datetime :recorded_at

      t.timestamps
    end
  end
end
