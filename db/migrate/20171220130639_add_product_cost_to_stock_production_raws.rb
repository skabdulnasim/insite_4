class AddProductCostToStockProductionRaws < ActiveRecord::Migration
  def change
  	add_column :stock_production_raws, :process_cost, :float
  end
end
