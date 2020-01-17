class AddTrashToCustomerQueues < ActiveRecord::Migration
  def change
    add_column :customer_queues, :trash, :integer
  end
end
