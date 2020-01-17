class CreateStockProductionMetaProcesses < ActiveRecord::Migration
  def change
    create_table :stock_production_meta_processes do |t|
      t.integer :stock_production_meta_id
      t.integer :target_product_id
      t.integer :production_process_id
      t.float :production_process_duration
      t.string :status

      t.timestamps
    end
  end
end
