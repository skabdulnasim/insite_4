class AddSortItemsByToMenuCards < ActiveRecord::Migration
  def change
    add_column :menu_cards, :sort_items_by, :string
    add_column :menu_cards, :sort_order, :string
  end
end
