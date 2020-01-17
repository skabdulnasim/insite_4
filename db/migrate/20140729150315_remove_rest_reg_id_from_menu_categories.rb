class RemoveRestRegIdFromMenuCategories < ActiveRecord::Migration
  def up
    remove_column :menu_products, :rest_reg_no
  end
end
