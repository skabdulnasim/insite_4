class AddSellPriceWithoutTaxToStockPrices < ActiveRecord::Migration
  def change
  	add_column :stock_prices, :sell_price_without_tax, :float
  end
end
