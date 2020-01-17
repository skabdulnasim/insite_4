class AddSkuToStockTransferMeta < ActiveRecord::Migration
  def change
    add_column :stock_transfer_meta, :sku, :string
  end
end
