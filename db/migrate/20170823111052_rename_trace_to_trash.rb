class RenameTraceToTrash < ActiveRecord::Migration
  def up
  	rename_column :reservations, :trace, :trash
  end

  def down
  end
end
