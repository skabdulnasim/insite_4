class AddStatusToResources < ActiveRecord::Migration
  def change
    add_column :resources, :status, :string, default: "enabled"
  end
end
