class AddResourceStateIdToResources < ActiveRecord::Migration
  def change
    add_column :resources, :resource_state_id, :integer
  end
end
