class AddDeviceIdToVisitingHistories < ActiveRecord::Migration
  def change
    add_column :visiting_histories, :device_id, :string
  end
end
