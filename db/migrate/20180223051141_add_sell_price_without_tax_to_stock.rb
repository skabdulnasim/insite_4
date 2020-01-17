class AddSellPriceWithoutTaxToStock < ActiveRecord::Migration
  def change
    add_column :stocks, :sell_price_without_tax, :float
  end
end
