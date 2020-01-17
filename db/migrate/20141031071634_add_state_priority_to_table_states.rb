class AddStatePriorityToTableStates < ActiveRecord::Migration
  def change
    add_column :table_states, :state_priority, :text
    add_column :table_states, :trash, :text
  end
end
