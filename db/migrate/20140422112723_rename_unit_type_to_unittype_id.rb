class RenameUnitTypeToUnittypeId < ActiveRecord::Migration
  def up
    rename_column :units, :unit_type, :unittype_id
  end

  def down
    rename_column :units, :unittype_id, :unit_type
  end
end
