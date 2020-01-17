class CreateResourceStatusLogs < ActiveRecord::Migration
  def change
    create_table :resource_status_logs do |t|
      t.integer :resource_type_id
      t.integer :resource_id
      t.integer :outlet_id
      t.integer :resource_state_id
      t.string :resource_state_name
      t.string :device_id
      t.integer :user_id

      t.timestamps
    end
  end
end
