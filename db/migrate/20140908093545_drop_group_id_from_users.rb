class DropGroupIdFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :group_id
  end

  def down
    remove_column :users, :group_id
  end
end
