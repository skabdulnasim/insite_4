class ChangeColorIdToBeIntegerInLots < ActiveRecord::Migration
  def change
    change_column :lots, :color_id, 'integer USING CAST(color_id AS integer)'
    change_column :lots, :size_id, 'integer USING CAST(size_id AS integer)'
  end
end
