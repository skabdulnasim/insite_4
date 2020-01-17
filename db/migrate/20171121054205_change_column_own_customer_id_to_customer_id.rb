class ChangeColumnOwnCustomerIdToCustomerId < ActiveRecord::Migration
  def up
  	rename_column :reservations, :own_customer_id, :customer_id
  end
end
