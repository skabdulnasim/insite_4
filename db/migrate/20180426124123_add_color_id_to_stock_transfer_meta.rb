class AddColorIdToStockTransferMeta < ActiveRecord::Migration
  def change
    add_column :stock_transfer_meta, :color_id, :integer
    add_column :stock_transfer_meta, :size_id, :integer
  end
end
