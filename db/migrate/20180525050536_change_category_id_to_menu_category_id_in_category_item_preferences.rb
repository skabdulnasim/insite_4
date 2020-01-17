class ChangeCategoryIdToMenuCategoryIdInCategoryItemPreferences < ActiveRecord::Migration
  def change
  	rename_column :category_item_preferences, :category_id, :menu_category_id
  end
end