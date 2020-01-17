class AddSizeIdColorIdToPurchaseOrderMeta < ActiveRecord::Migration
  def change
    add_column :purchase_order_meta, :size_id, :integer
    add_column :purchase_order_meta, :color_id, :integer
  end
end
