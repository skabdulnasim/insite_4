class RenameColumnComboItemIdToComboItems < ActiveRecord::Migration
  def up
  	if column_exists? :combo_items, :combo_item_id
  		rename_column :combo_items, :combo_item_id, :item_id
  	end	
  end
end
