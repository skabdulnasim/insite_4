class AddGrnNoToStockPurchases < ActiveRecord::Migration
  def change
    add_column :stock_purchases, :grn_no, :string
  end
end
