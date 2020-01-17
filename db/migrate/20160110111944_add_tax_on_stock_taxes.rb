class AddTaxOnStockTaxes < ActiveRecord::Migration
  def up
    add_column :stock_prices, :tax_applicable_on, :string
    add_column :stock_prices, :addon_cost_remarks, :string
  end

  def down
    remove_column :stock_prices, :tax_applicable_on
    remove_column :stock_prices, :addon_cost_remarks
  end
end
