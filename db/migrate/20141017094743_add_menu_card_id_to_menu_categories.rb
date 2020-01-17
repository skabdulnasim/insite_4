class AddMenuCardIdToMenuCategories < ActiveRecord::Migration
  def change
    add_column :menu_categories, :menu_card_id, :integer
  end
end
