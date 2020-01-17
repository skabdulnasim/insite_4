class AddUserIdToTables < ActiveRecord::Migration
  def change
    add_column :tables, :user_id, :integer
  end
end
