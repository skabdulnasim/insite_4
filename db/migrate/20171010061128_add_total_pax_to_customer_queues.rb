class AddTotalPaxToCustomerQueues < ActiveRecord::Migration
  def change
    add_column :customer_queues, :total_pax, :string
    add_column :customer_queues, :is_reserved, :integer
  end
end
