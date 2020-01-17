class RemoveIconFromCustomerState < ActiveRecord::Migration
  def change
  	remove_column :customer_states, :icon
  end
end
