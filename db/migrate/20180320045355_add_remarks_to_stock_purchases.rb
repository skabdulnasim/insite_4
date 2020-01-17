class AddRemarksToStockPurchases < ActiveRecord::Migration
  def change
    add_column :stock_purchases, :remarks, :text
  end
end
