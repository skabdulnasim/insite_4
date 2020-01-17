class AddRecordedAtToResources < ActiveRecord::Migration
  def change
    add_column :resources, :recorded_at, :datetime
  end
end
