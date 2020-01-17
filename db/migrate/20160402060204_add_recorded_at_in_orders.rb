class AddRecordedAtInOrders < ActiveRecord::Migration
  def change
    add_column :orders, :recorded_at, :datetime
    add_column :bills, :recorded_at, :datetime
    add_column :settlements, :recorded_at, :datetime
    if column_exists? :orders, :recorded_at
      Order.update_all("recorded_at=created_at")
    end
    if column_exists? :bills, :recorded_at
      Bill.update_all("recorded_at=created_at")
    end
    if column_exists? :settlements, :recorded_at
      Settlement.update_all("recorded_at=created_at")
    end    
  end
end
