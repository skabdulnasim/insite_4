class CreateReservationSwapLogs < ActiveRecord::Migration
  def change
    create_table :reservation_swap_logs do |t|
      t.string :device_id
      t.integer :reservation_id
      t.integer :old_resource_id
      t.integer :new_resource_id
      t.integer :user_id
      t.integer :unit_id

      t.timestamps
    end
  end
end
