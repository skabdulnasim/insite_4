class RenameCategoryToCategoryId < ActiveRecord::Migration
  def up
    rename_column :products, :category, :category_id
  end

  def down
    rename_column :products, :category_id, :category
  end
end
