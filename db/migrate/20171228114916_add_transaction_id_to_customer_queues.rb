class AddTransactionIdToCustomerQueues < ActiveRecord::Migration
  def change
    add_column :customer_queues, :transaction_id, :string
  end
end
