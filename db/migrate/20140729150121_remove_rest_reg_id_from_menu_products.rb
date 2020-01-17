class RemoveRestRegIdFromMenuProducts < ActiveRecord::Migration
  def up
    remove_column :menu_categories, :rest_reg_no
  end
end
