class Add < ActiveRecord::Migration
  def up
  	add_column :customer_queues, :customer_queue_state_id, :integer
  end

  def down
  	remove_column :customer_queues, :customer_queue_state_id, :integer
  end
end
