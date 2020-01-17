class AddSecondaryQuantityToPurchaseOrderMeta < ActiveRecord::Migration
  def change
    add_column :purchase_order_meta, :secondary_amount, :float
    add_column :purchase_order_meta, :secondary_product_unit_id, :integer
  end
end
