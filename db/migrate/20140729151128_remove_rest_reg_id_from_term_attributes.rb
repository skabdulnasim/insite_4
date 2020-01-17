class RemoveRestRegIdFromTermAttributes < ActiveRecord::Migration
  def up
    remove_column :term_attributes, :rest_reg_no
  end
end
