class CreateCategoryItemPreferences < ActiveRecord::Migration
  def change
    create_table :category_item_preferences do |t|
      t.references :category
      t.references :item_preference

      t.timestamps
    end
    add_index :category_item_preferences, :category_id
    add_index :category_item_preferences, :item_preference_id
  end
end
