class RemoveRestRegIdFromProductUnits < ActiveRecord::Migration
  def up
    remove_column :product_units, :rest_reg_no
  end
end
