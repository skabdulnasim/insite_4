class AddSetIntervalIdToStockProductionMetaProcesses < ActiveRecord::Migration
  def change
  	add_column :stock_production_meta_processes, :setIntervalId, :integer
  end
end
