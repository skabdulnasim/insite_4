class ChangeRowUniqueIdFieldType < ActiveRecord::Migration
  def up
  	change_column :warehouse_meta, :row_unique_id, :string
  end

  def down
  	change_column :warehouse_meta, :row_unique_id, :integer
  end
end
