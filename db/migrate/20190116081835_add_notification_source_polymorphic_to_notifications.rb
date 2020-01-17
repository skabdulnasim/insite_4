class AddNotificationSourcePolymorphicToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :notification_source_type, :string
    add_column :notifications, :notification_source_id, :integer
  end
end
