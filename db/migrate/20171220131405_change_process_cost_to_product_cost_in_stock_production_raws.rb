class ChangeProcessCostToProductCostInStockProductionRaws < ActiveRecord::Migration
  def change
  	rename_column :stock_production_raws, :process_cost, :product_cost
  end
end
