class RemoveIconFromTag < ActiveRecord::Migration
  def change
  	remove_column :tags, :icon
  end
end
