class RenameMarginToMarginOnMrpInStockPrices < ActiveRecord::Migration
  def change
  	rename_column :stock_prices, :margin, :margin_on_mrp
  end
end