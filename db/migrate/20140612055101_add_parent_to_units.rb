class AddParentToUnits < ActiveRecord::Migration
  def change
    add_column :units, :unit_parent, :integer
  end
end
