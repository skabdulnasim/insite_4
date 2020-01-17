class CreateAvailabilities < ActiveRecord::Migration
  def change
    create_table :availabilities do |t|
      t.date :available_date
      t.references :slot
      t.references :resource

      t.timestamps
    end
    add_index :availabilities, :slot_id
    add_index :availabilities, :resource_id
  end
end
