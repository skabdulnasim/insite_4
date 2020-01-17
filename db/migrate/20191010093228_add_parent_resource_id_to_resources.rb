class AddParentResourceIdToResources < ActiveRecord::Migration
  def change
    add_column :resources, :parent_resource_id, :integer
  end
end
