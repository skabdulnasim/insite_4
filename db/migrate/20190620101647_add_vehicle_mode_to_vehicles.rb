class AddVehicleModeToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :vehicle_mode, :string
  end
end
