class AddCustomerStateTransitionIdToCustomerCommunication < ActiveRecord::Migration
  def change
    add_column :customer_communications, :customer_state_transition_id, :int
  end
end
