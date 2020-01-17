class AddUnitIdToZones < ActiveRecord::Migration
  def change
    add_column :zones, :unit_id, :integer
  end
end
