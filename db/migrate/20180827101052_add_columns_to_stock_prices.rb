class AddColumnsToStockPrices < ActiveRecord::Migration
  def change
  	add_column :stock_prices, :purchase_cost, :float
  	add_column :stock_prices, :margin, :float
  	add_column :stock_prices, :volume_discount, :float
  	add_column :stock_prices, :scheme_discount, :float
  	add_column :stock_prices, :scheme_discount_by_amount, :float
  end
end
