class AddStatusToStockTransferMeta < ActiveRecord::Migration
  def change
    add_column :stock_transfer_meta, :status, :string
  end
end
