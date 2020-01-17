class RenameProductStockToProductId < ActiveRecord::Migration
  def up
    rename_column :purchase_order_stocks, :product_stock, :product_id
    rename_column :purchase_order_stocks, :po_stock, :product_stock
  end

  def down
  end
end
