class AddDeviceIdToSettlements < ActiveRecord::Migration
  def change
    add_column :settlements, :device_id, :string
    change_column :bills, :device_id, :string
    change_column :orders, :device_id, :string
    change_column :table_status_logs, :device_id, :string
  end
end
