class AddRecordedAtToCashIn < ActiveRecord::Migration
  def change
    add_column :cash_ins, :recorded_at, :datetime
  end
end
