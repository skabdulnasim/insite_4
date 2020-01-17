class CreateResourceOrderHistoryDetails < ActiveRecord::Migration
  def change
    create_table :resource_order_history_details do |t|
      t.integer :menu_product_id
      t.integer :product_id
      t.string :product_name
      t.integer :user_id
      t.integer :unit_id
      t.integer :resource_id
      t.datetime :recorded_at
      t.text :remrks
      t.integer :resource_order_history_id
      t.float :quantity
      t.string :hsn_code
      t.timestamps
    end
  end
end
