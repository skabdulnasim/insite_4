class AddVehicleIdToProformas < ActiveRecord::Migration
  def change
    add_column :proformas, :vehicle_id, :integer
  end
end
