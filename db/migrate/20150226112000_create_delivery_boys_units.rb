class CreateDeliveryBoysUnits < ActiveRecord::Migration
  def change
    create_table :delivery_boys_units do |t|
      t.references :delivery_boy
      t.references :unit
      t.integer :account_id

      t.timestamps
    end
    add_index :delivery_boys_units, :delivery_boy_id
    add_index :delivery_boys_units, :unit_id
  end
end
