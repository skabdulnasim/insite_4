class CreateMenuCardMenuCategories < ActiveRecord::Migration
  def change
    create_table :menu_card_menu_categories do |t|
      t.integer :menu_card_id
      t.integer :menu_category_id

      t.timestamps
    end
  end
end
