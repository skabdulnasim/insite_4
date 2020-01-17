class RemoveConjugatedUnitIdAndPhysicalTypeIdFromProductionProcesses < ActiveRecord::Migration
  def change
  	remove_column :production_processes, :conjugated_unit_id
  	remove_column :production_processes, :physical_type_id
  end
end
