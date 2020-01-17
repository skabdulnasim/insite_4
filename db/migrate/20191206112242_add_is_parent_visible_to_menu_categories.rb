class AddIsParentVisibleToMenuCategories < ActiveRecord::Migration
  def change
    add_column :menu_categories, :is_parent_visible, :boolean
  end
end
