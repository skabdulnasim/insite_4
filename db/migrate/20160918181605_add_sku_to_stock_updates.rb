class AddSkuToStockUpdates < ActiveRecord::Migration
  def change
    add_column :stock_updates, :sku, :string
    add_column :stock_updates, :sku_stock, :float
  end
end
