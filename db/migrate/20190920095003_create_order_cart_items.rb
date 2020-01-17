class CreateOrderCartItems < ActiveRecord::Migration
  def change
    create_table :order_cart_items do |t|
      t.integer :order_cart_id
      t.integer :customer_id
      t.integer :menu_product_id
      t.float :quantity
      t.integer :product_id
      t.integer :lot_id
      t.integer :color_id
      t.integer :size_id
      t.integer :model_no
      t.boolean :stock_status
      t.string :status

      t.timestamps
    end
  end
end
