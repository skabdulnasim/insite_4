class AddUniqueConstraintToStatePriorityInTableStates < ActiveRecord::Migration
  def change
    add_index :table_states, [:state_priority], :unique => true
  end
end
