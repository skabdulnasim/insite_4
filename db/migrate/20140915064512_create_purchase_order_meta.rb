class CreatePurchaseOrderMeta < ActiveRecord::Migration
  def change
    create_table :purchase_order_meta do |t|
      t.integer :purchase_order_id
      t.integer :product_id
      t.float :product_amount

      t.timestamps
    end
  end
end
