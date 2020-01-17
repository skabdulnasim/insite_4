class AddStatusToPurchaseOrderMetas < ActiveRecord::Migration
  def change
    add_column :purchase_order_meta, :status, :string
  end
end
