class ChangeSizeToSizeNameToStockTransferMeta < ActiveRecord::Migration
  def change
  	rename_column :stock_transfer_meta, :size, :size_name
  end
end
