class AddSellPriceWithoutTaxToMenuProducts < ActiveRecord::Migration
  def change
    add_column :menu_products, :sell_price_without_tax, :float
  end
end
