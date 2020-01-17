class AddColumnsToStockPurchases < ActiveRecord::Migration
  def change
    add_column :stock_purchases, :travelling_cost, :float
    add_column :stock_purchases, :total_discount, :float
  end
end
