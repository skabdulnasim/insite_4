class RenameStateToTableStateId < ActiveRecord::Migration
  def up
    rename_column :tables, :state, :table_state_id
  end

  def down
  end
end
