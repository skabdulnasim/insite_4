class AddCapacityToResources < ActiveRecord::Migration
  def change
    add_column :resources, :capacity, :integer
  end
end
