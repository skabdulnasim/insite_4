class AddUnitIdToUnitDetails < ActiveRecord::Migration
  def change
    add_column :unit_details, :unit_id, :integer
  end
end
