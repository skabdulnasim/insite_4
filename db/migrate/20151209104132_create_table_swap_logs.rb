class CreateTableSwapLogs < ActiveRecord::Migration
  def change
    create_table :table_swap_logs do |t|
      t.integer :order_id
      t.integer :old_table_id
      t.integer :old_table_state_before_update
      t.integer :new_table_id
      t.integer :new_table_state_before_update
      t.integer :user_id
      t.integer :device_id

      t.timestamps
    end
  end
end
