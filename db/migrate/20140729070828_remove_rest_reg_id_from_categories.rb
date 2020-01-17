class RemoveRestRegIdFromCategories < ActiveRecord::Migration
  def up
    remove_column :categories, :rest_reg_no
  end
end
