class RemoveTaxOnFromStockPrices < ActiveRecord::Migration
  def up
    remove_column :stock_prices, :tax_applicable_on
    add_column :stock_taxes, :tax_applicable_on, :string
  end

  def down
  end
end
