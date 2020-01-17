class AddRecordedAtToUserVendors < ActiveRecord::Migration
  def change
    add_column :user_vendors, :recorded_at, :datetime
  end
end
