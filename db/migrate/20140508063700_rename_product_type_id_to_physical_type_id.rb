class RenameProductTypeIdToPhysicalTypeId < ActiveRecord::Migration
  def up
    rename_column :products, :product_type_id, :physical_type_id
  end

  def down
    rename_column :products, :physical_type_id, :product_type_id
  end
end
