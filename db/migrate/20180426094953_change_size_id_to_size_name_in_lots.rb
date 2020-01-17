class ChangeSizeIdToSizeNameInLots < ActiveRecord::Migration
  def change
  	remove_column :lots, :size_id
  	remove_column :lots, :color_id
  	add_column :lots, :color_name, :string
  	add_column :lots, :size_name, :string
  end
end
