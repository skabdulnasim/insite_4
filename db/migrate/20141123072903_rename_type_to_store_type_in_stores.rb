class RenameTypeToStoreTypeInStores < ActiveRecord::Migration
  def up
    rename_column :stores, :type, :store_type
  end

  def down
  end
end
