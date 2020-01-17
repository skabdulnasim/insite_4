class CreateVehicles < ActiveRecord::Migration
  def change
    create_table :vehicles do |t|
      t.string :name
      t.integer :unit_id
      t.string :contact_no
      t.string :pincode
      t.string :license_no
      t.string :vehicle_image

      t.timestamps
    end
  end
end
