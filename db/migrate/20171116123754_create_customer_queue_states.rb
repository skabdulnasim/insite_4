class CreateCustomerQueueStates < ActiveRecord::Migration
  def change
    create_table :customer_queue_states do |t|
      t.string :name
      t.string :color_code
      t.string :trash

      t.timestamps
    end
  end
end
