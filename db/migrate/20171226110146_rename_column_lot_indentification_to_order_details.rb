class RenameColumnLotIndentificationToOrderDetails < ActiveRecord::Migration
  def up
  	rename_column :order_details, :lot_identification, :stock_id
  end
end
