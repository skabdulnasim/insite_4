class AddIsTrashedToProductionProcesses < ActiveRecord::Migration
  def change
  	add_column :production_processes, :is_trashed, :boolean, default: false 
  end
end
