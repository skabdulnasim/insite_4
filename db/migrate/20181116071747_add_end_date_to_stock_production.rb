class AddEndDateToStockProduction < ActiveRecord::Migration
  def change
    add_column :stock_productions, :end_date, :datetime
  end
end
