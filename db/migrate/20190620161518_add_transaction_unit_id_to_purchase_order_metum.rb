class AddTransactionUnitIdToPurchaseOrderMetum < ActiveRecord::Migration
  def change
    add_column :purchase_order_meta, :transaction_unit_id, :integer
  end
end
