class AddMenuCategoryImageToMenuCategorie < ActiveRecord::Migration
  def change
    add_column :menu_categories, :menu_category_image, :string
  end
end
