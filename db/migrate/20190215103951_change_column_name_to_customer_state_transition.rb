class ChangeColumnNameToCustomerStateTransition < ActiveRecord::Migration
  def change
  	rename_column :customer_state_transitions, :recorder_at, :recorded_at
  end
end
