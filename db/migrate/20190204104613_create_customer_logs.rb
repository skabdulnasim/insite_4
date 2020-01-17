class CreateCustomerLogs < ActiveRecord::Migration
  def change
    create_table :customer_logs do |t|
      t.integer :customer_id
      t.integer :tag_id
      t.datetime :recorded_at
      t.string :customer_state_id

      t.timestamps
    end
  end
end
