class AddColumnsToStockProductionMetaProcess < ActiveRecord::Migration
  def change
    add_column :stock_production_meta_processes, :actual_start_time, :time
    add_column :stock_production_meta_processes, :actual_end_time, :time
    add_column :stock_production_meta_processes, :expected_end_time, :time
  end
end
