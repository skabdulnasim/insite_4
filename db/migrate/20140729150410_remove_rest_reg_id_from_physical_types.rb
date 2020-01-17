class RemoveRestRegIdFromPhysicalTypes < ActiveRecord::Migration
  def up
    remove_column :physical_types, :rest_reg_no
  end
end
