class RemoveRestRegIdFromUnits < ActiveRecord::Migration
  def up
    remove_column :units, :rest_reg_no
  end
end
