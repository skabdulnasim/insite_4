class AddRecordedAtToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :recorded_at, :datetime
  end
end
