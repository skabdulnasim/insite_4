class RenameColorToColorIdInLots < ActiveRecord::Migration
  def change
    rename_column :lots, :color, :color_id
    rename_column :lots, :size, :size_id
  end
end
