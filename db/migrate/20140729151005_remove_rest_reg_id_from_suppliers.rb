class RemoveRestRegIdFromSuppliers < ActiveRecord::Migration
  def up
    remove_column :suppliers, :rest_reg_no
  end
end
