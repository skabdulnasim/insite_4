class AddCustomerIdToBills < ActiveRecord::Migration
  def change
    add_column :bills, :customer_id, :integer
  end
end
