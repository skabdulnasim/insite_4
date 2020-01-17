class AddCustomSyncToUsers < ActiveRecord::Migration
  def change
    add_column :users, :custom_sync, :string
  end
end
