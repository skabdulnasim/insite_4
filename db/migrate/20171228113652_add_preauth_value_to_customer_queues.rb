class AddPreauthValueToCustomerQueues < ActiveRecord::Migration
  def change
    add_column :customer_queues, :preauth_value, :float
  end
end
