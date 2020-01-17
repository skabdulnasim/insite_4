class AddStartDateToStockProduction < ActiveRecord::Migration
  def change
    add_column :stock_productions, :start_date, :datetime
  end
end
