class RemoveBasicUnitIdFromProductionProcesses < ActiveRecord::Migration
  def change
  	remove_column :production_processes, :basic_unit_id
  end
end
