class AddSmartPoIdToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :smart_po_id, :integer
  end
end
