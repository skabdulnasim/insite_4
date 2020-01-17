class RenameSellPriceWithoutTaxToSellPriceWithTaxInStocks < ActiveRecord::Migration
  def change
  	rename_column :stocks, :sell_price_without_tax, :sell_price_with_tax
  end
end