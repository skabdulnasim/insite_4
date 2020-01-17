class AddSalesPercentageToStockPrice < ActiveRecord::Migration
  def change
    add_column :stock_prices, :sales_percentage, :float
  end
end
