class RenameTotalDiscountToDiscountOnPoInStockPurchases < ActiveRecord::Migration
  def change
  	rename_column :stock_purchases, :total_discount, :discount_on_po
  end
end