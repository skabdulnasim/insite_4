class AddCustomerUniqueIdToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :customer_unique_id, :string
  end
end
