class AddExtraFieldsToCustomerState < ActiveRecord::Migration
  def change
    add_column :customer_states, :icon, :string
    add_column :customer_states, :color, :string
    add_column :customer_states, :status, :string
  end
end
