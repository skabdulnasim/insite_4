class AddMenuClassificationToMenuCards < ActiveRecord::Migration
  def change
    add_column :menu_cards, :menu_classification, :string
  end
end
