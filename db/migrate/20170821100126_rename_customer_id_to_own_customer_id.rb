class RenameCustomerIdToOwnCustomerId < ActiveRecord::Migration
  def up
  	rename_column :reservations, :customer_id, :own_customer_id
  end

  def down
  end
end
