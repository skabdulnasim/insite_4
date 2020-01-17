class ChangeUnitIdToNotifications < ActiveRecord::Migration
  def up
    change_column :notifications, :unit_id, :integer, :null => true
  end

  def down
    change_column :notifications, :unit_id, :integer, :null => false
  end
end
