class CreateDeliveryCharges < ActiveRecord::Migration
  def change
    create_table :delivery_charges do |t|
      t.float :lower_limit
      t.float :upper_limit
      t.float :delivery_charge
      t.integer :unit_id

      t.timestamps
    end
  end
end
