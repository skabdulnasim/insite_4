class AddColorIdToLots < ActiveRecord::Migration
  def change
    add_column :lots, :color_id, :integer
    add_column :lots, :size_id, :integer
  end
end
