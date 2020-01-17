class AddSellPriceWithoutTaxToReturnItems < ActiveRecord::Migration
  def change
    add_column :return_items, :sell_price_without_tax, :float
  end
end
