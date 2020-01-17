class CreateTableStatusLogs < ActiveRecord::Migration
  def change
    create_table :table_status_logs do |t|
      t.integer :outlet_id
      t.integer :table_id
      t.integer :table_state_id
      t.text :table_state_name
      t.integer :user_id

      t.timestamps
    end
  end
end
