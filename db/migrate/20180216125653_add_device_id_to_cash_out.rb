class AddDeviceIdToCashOut < ActiveRecord::Migration
  def change
    add_column :cash_outs, :device_id, :string
  end
end
