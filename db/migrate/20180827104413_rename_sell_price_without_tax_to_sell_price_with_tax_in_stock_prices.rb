class RenameSellPriceWithoutTaxToSellPriceWithTaxInStockPrices < ActiveRecord::Migration
  def change
  	rename_column :stock_prices, :sell_price_without_tax, :sell_price_with_tax
  end
end