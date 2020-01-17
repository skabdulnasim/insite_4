class ChangeColumnNameTableSatus < ActiveRecord::Migration
  def change
     rename_column :tables, :status, :reservation_status
     
  end
end
