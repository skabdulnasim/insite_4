class AddRoleIdToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :role_id, :integer
  end
end
