class AddDeviceIdToTableStatusLogs < ActiveRecord::Migration
  def change
    add_column :table_status_logs, :device_id, :integer
  end
end
