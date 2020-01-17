class AddCustomerStateIdToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :customer_state_id, :integer
  end
end
