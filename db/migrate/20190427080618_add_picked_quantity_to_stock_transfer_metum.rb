class AddPickedQuantityToStockTransferMetum < ActiveRecord::Migration
  def change
    add_column :stock_transfer_meta, :picked_quantity, :integer
  end
end
