class AddCustomerIdToResources < ActiveRecord::Migration
  def change
    add_column :resources, :customer_id, :integer
  end
end
