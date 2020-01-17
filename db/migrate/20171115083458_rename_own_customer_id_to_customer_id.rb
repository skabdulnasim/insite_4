class RenameOwnCustomerIdToCustomerId < ActiveRecord::Migration
  def up
  	rename_column :customer_queues, :own_customer_id, :customer_id
  end

  def down
  	rename_column :customer_queues, :customer_id, :own_customer_id
  end
end
