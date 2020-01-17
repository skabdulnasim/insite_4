class CreatePurchaseOrders < ActiveRecord::Migration
  def change
    create_table :purchase_orders do |t|
      t.string :name
      t.date :valid_from
      t.date :valid_till
      t.integer :mode
      t.integer :store_id
      t.integer :unit_id
      t.integer :user_id
      t.integer :recurring
      t.integer :vendor_id
      t.text :purchase_order_code

      t.timestamps
    end
  end
end
