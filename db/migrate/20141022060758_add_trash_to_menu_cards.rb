class AddTrashToMenuCards < ActiveRecord::Migration
  def change
    add_column :menu_cards, :trash, :integer
  end
end
