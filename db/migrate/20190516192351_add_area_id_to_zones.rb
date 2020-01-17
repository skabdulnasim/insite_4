class AddAreaIdToZones < ActiveRecord::Migration
  def change
    add_column :zones, :area_id, :integer
  end
end
