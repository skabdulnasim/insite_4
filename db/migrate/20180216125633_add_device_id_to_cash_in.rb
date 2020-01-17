class AddDeviceIdToCashIn < ActiveRecord::Migration
  def change
    add_column :cash_ins, :device_id, :string
  end
end
