class RenameProductTypeToBusinessType < ActiveRecord::Migration
  def up
    rename_column :products, :product_type, :business_type
  end

  def down
    rename_column :products, :business_type, :product_type
  end
end
