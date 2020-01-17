class AddBalanceToStockPurchases < ActiveRecord::Migration
  def change
    add_column :stock_purchases, :total_amount, :float
    add_column :stock_purchases, :paida_mount, :float
  end
end
