class AddColorIdAndSizeIdToLogItems < ActiveRecord::Migration
  def change
    add_column :log_items, :color_id, :integer
    add_column :log_items, :size_id, :integer
  end
end
