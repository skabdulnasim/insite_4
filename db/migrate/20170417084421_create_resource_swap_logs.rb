class CreateResourceSwapLogs < ActiveRecord::Migration
  def change
    create_table :resource_swap_logs do |t|
      t.integer :order_id
      t.integer :old_resource_id
      t.integer :old_resource_state_before_update
      t.integer :new_resource_id
      t.integer :new_resource_state_before_update
      t.integer :user_id
      t.string :device_id

      t.timestamps
    end
  end
end
