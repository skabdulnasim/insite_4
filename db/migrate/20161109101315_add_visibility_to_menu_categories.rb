class AddVisibilityToMenuCategories < ActiveRecord::Migration
  def change
    add_column :menu_categories, :is_visible, :boolean, :default => true
  end
end
