class AddUnitPriceWithTaxToBillSplitProducts < ActiveRecord::Migration
  def change
    add_column :bill_split_products, :unit_price_with_tax, :float
  end
end
