class AddRecordedAtToCashOut < ActiveRecord::Migration
  def change
    add_column :cash_outs, :recorded_at, :datetime
  end
end
