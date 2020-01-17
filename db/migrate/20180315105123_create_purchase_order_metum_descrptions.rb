class CreatePurchaseOrderMetumDescrptions < ActiveRecord::Migration
  def change
    create_table :purchase_order_metum_descrptions do |t|
      t.integer :purchase_order_id
      t.integer :purchase_order_metum_id
      t.integer :product_id
      t.integer :color_id
      t.integer :size_id
      t.float :quentity

      t.timestamps
    end
  end
end
