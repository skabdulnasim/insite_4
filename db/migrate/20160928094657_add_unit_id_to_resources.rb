class AddUnitIdToResources < ActiveRecord::Migration
  def change
    add_column :resources, :unit_id, :integer
    add_column :resources, :section_id, :integer
    add_index :resources, :unit_id
    add_index :resources, :section_id
  end
end
