class AddImageToMenuCategory < ActiveRecord::Migration
  def up
  	add_attachment :menu_categories, :image	
  end
  
  def down
  	add_attachment :menu_categories, :image
  end
end
