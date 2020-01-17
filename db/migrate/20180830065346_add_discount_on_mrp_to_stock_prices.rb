class AddDiscountOnMrpToStockPrices < ActiveRecord::Migration
  def change
    add_column :stock_prices, :discount_on_mrp, :float
  end
end
