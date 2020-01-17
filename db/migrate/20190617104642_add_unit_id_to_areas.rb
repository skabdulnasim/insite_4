class AddUnitIdToAreas < ActiveRecord::Migration
  def change
    add_column :areas, :unit_id, :integer
  end
end
