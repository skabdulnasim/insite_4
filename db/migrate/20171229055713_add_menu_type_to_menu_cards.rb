class AddMenuTypeToMenuCards < ActiveRecord::Migration
  def change
    add_column :menu_cards, :menu_type, :string
  end
end
