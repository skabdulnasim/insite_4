class AddSectionIdToMenuCards < ActiveRecord::Migration
  def change
    add_column :menu_cards, :section_id, :integer
  end
end
