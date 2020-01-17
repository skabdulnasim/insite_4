class CreateOrderDetails < ActiveRecord::Migration
  def change
    create_table :order_details do |t|
      t.integer :order_id
      t.integer :menu_product_id
      t.string :menu_product_name
      t.integer :quantity

      t.timestamps
    end
  end
end
