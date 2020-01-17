class RemoveRestRegIdFromMenuCards < ActiveRecord::Migration
  def up
    remove_column :menu_cards, :rest_reg_no
  end
end
