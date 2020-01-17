class AddSortOrderToMenuCategories < ActiveRecord::Migration
  def change
    add_column :menu_categories, :sort_order, :integer
  end
end
