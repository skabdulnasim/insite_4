class AddRecordedAtToBillSplits < ActiveRecord::Migration
  def change
    add_column :bill_splits, :recorded_at, :datetime
  end
end
