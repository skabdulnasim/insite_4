class ChangeCustomSyncDefaultValueInUsers < ActiveRecord::Migration
  def change
  	change_column_default :users, :custom_sync, 'disable'
  end
end
