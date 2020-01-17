class AddDeviceIdToPay < ActiveRecord::Migration
  def change
    add_column :pays, :device_id, :string
  end
end
