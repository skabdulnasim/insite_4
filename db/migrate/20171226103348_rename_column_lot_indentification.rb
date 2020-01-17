class RenameColumnLotIndentification < ActiveRecord::Migration
  def up
  	rename_column :lots, :lot_indentification, :stock_id
  end
end
