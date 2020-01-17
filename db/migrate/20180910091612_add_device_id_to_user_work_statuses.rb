class AddDeviceIdToUserWorkStatuses < ActiveRecord::Migration
  def change
    add_column :user_work_statuses, :device_id, :string
  end
end
