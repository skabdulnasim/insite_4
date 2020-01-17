class RemoveRestRegIdFromProducts < ActiveRecord::Migration
  def up
    remove_column :products, :rest_reg_no
  end
end
