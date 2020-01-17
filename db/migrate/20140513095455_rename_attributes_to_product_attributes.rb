class RenameAttributesToProductAttributes < ActiveRecord::Migration
  def up
    rename_column :products, :attributes, :product_attributes
  end

  def down
    rename_column :products, :product_attributes, :attributes
  end
end
