class AddDeviceIdToReturnItems < ActiveRecord::Migration
  def change
    add_column :return_items, :device_id, :string
    add_column :return_items, :user_id, :integer
  end
end
