class AddSlotIdToCustomerQueues < ActiveRecord::Migration
  def change
    add_column :customer_queues, :slot_id, :integer
  end
end
