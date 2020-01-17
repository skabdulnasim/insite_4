class RenameStockTransferUnitToProductTransactionUnitId < ActiveRecord::Migration
  def up
  	rename_column(:stock_transfer_meta,:stock_transfer_unit,:product_transaction_unit_id)
  end
end
