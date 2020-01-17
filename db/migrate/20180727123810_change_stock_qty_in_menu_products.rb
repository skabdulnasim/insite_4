class ChangeStockQtyInMenuProducts < ActiveRecord::Migration
  def up
    change_column :menu_products, :stock_qty, :float
  end
end
