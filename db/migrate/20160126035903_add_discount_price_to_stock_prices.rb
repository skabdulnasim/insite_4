class AddDiscountPriceToStockPrices < ActiveRecord::Migration
  def change
    add_column :stock_prices, :discount_price, :float
    remove_column :stocks, :discount_price
  end
end
