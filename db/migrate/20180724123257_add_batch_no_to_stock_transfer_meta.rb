class AddBatchNoToStockTransferMeta < ActiveRecord::Migration
  def change
    add_column :stock_transfer_meta, :batch_no, :string
  end
end
