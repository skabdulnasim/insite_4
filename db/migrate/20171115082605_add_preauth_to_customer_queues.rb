class AddPreauthToCustomerQueues < ActiveRecord::Migration
  def change
    add_column :customer_queues, :preauth, :boolean, :default => false
  end
end
