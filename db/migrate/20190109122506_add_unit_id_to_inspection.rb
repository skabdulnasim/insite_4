class AddUnitIdToInspection < ActiveRecord::Migration
  def change
    add_column :inspections, :unit_id, :int
  end
end
