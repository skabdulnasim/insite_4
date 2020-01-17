class AddStockTransferUnitToStockTransferMeta < ActiveRecord::Migration
  def change
    add_column :stock_transfer_meta, :stock_transfer_unit, :string
  end
end
