class RenameRawToMetaValue < ActiveRecord::Migration
  def up
    rename_column :product_meta, :raw, :meta_value
  end

  def down
    rename_column :product_meta, :meta_value, :raw
  end
end
