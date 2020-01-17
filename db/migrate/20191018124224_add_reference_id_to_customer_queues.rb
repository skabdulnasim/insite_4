class AddReferenceIdToCustomerQueues < ActiveRecord::Migration
  def change
    add_column :customer_queues, :reference_id, :integer
  end
end
