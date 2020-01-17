class AddProcessImageToProductionProcesses < ActiveRecord::Migration
  def up
	add_attachment :production_processes, :process_image
  end

  def down
	remove_attachment :production_processes, :process_image
  end
end