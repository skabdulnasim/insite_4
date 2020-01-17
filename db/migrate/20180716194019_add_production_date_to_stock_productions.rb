class AddProductionDateToStockProductions < ActiveRecord::Migration
  def change
    add_column :stock_productions, :production_date, :datetime
  end
end
