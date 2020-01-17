class ChangeDeviceIdToBeStringInPreauths < ActiveRecord::Migration
  def change
  	change_column :preauths, :device_id, :string
  end
end
