class AddPassKeyToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :pass_key, :string
  end
end
