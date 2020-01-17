class AddProcessCostToStockProductionMetaProcesses < ActiveRecord::Migration
  def change
  	add_column :stock_production_meta_processes, :process_cost, :float
  end
end
