class AddMasterMenuIdToMenuCards < ActiveRecord::Migration
  def change
    add_column :menu_cards, :master_menu_id, :integer
  end
end
