class CreateCustomerStateTransitions < ActiveRecord::Migration
  def change
    create_table :customer_state_transitions do |t|
      t.integer :customer_id
      t.integer :user_id
      t.integer :customer_state_id
      t.datetime :recorder_at

      t.timestamps
    end
  end
end
