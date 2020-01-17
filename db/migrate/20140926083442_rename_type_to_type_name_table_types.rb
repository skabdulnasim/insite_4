class RenameTypeToTypeNameTableTypes < ActiveRecord::Migration
  def up
    rename_column :table_types, :type, :type_name
  end

  def down
  end
end
