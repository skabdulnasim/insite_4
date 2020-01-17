class AddImagePriorityPositionToMenuCards < ActiveRecord::Migration
  def change
  	add_attachment :menu_cards, :image
  	add_column :menu_cards, :priority, :string
  	add_column :menu_cards, :position, :string
  end
end
