class AddUnitIdToMenuCards < ActiveRecord::Migration
  def change
    add_column :menu_cards, :unit_id, :integer
  end
end
