class RenameOutletIdToUnitIdInTables < ActiveRecord::Migration
  def up
      rename_column :tables, :outlet_id, :unit_id
  end

  def down
  end
end
