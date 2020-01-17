class CreateOrderCarts < ActiveRecord::Migration
  def change
    create_table :order_carts do |t|
      t.integer :customer_id
      t.integer :unit_id
      t.float :total_item

      t.timestamps
    end
  end
end
