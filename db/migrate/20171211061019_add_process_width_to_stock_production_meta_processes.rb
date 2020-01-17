class AddProcessWidthToStockProductionMetaProcesses < ActiveRecord::Migration
  def change
  	add_column :stock_production_meta_processes, :process_width, :string
  end
end