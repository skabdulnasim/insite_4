class AddPriorityToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :priority, :string
    change_column :notifications, :title, :string
  end
end
